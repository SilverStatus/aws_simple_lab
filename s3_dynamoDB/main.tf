# Specifies the required Terraform version and AWS Provider version.
terraform {
  required_version = ">= 0.14"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92.0"
    }
  }
}

# Sets our region to "us-east-1"
provider "aws" {
  region = "us-east-1"
}

# create s3 bucket for microk8s
resource "aws_s3_bucket" "terraform-microk8s" {
    bucket = "terraform-101001"
    force_destroy = "true" # Allow force destroy for testing purposes 
    tags = {
        Name = "terraform-microk8s"
        description = "terraform S3 bucket"
    }
}

# create dynamodb table for state locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform_locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "terraform_locks"
    Environment = "Terraform"
  }
  
}

# create ECR repository
resource "aws_ecr_repository" "my_ecr_repo" {
  name = "my-ecr-repo"
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Name        = "my-ecr-repo"
    Environment = "Terraform"
  }
  
}

# Create an ECR repository policy to allow pull access
resource "aws_ecr_repository_policy" "my_ecr_repo_policy" {
  repository = aws_ecr_repository.my_ecr_repo.name
  policy     = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "AllowPull",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
          "arn:aws:iam::084828586638:policy/MinikubeECRAccess"
        ]
      },
      "Action": [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability",
        "ecr:CompleteLayerUpload",
        "ecr:InitiateLayerUpload",
        "ecr:PutImage",
        "ecr:UploadLayerPart"
      ]
    }
  ]
}
EOF
}

#data source that queries information about the AWS account and credentials currently in use
data "aws_caller_identity" "current" {}

# Optional: Lifecycle policy to clean up old images
resource "aws_ecr_lifecycle_policy" "my_ecr_repo_lifecycle" {
  repository = aws_ecr_repository.my_ecr_repo.name

  policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Keep last 30 images",
      "selection": {
        "tagStatus": "any",
        "countType": "imageCountMoreThan",
        "countNumber": 30
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
}

resource "kubernetes_service_account" "ecr_sa" {
  metadata {
    name = "ecr-service-account"
  }
}

