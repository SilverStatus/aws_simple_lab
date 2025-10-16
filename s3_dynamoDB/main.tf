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
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
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

# Create IAM User
resource "aws_iam_user" "git_user" {
  name = "git-user"
  path = "/"

  tags = {
    Name        = "Git User"
    Environment = "Production"
  }
}

# Attach S3 Full Access Policy
resource "aws_iam_user_policy_attachment" "s3_admin" {
  user       = aws_iam_user.git_user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# Attach EC2 Full Access Policy
resource "aws_iam_user_policy_attachment" "ec2_admin" {
  user       = aws_iam_user.git_user.name       
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

# Attach VPC Full Access Policy
resource "aws_iam_user_policy_attachment" "vpc_admin" {
  user       = aws_iam_user.git_user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
}

# Create custom policy for ALB admin access
resource "aws_iam_policy" "alb_admin" {
  name        = "ALBAdminPolicy"
  description = "Policy for full ALB administration"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:*"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach ALB Admin Policy
resource "aws_iam_user_policy_attachment" "alb_admin" {
  user       = aws_iam_user.git_user.name
  policy_arn = aws_iam_policy.alb_admin.arn
}

# Create custom policy for Security Group admin access
resource "aws_iam_policy" "sg_admin" {
  name        = "SecurityGroupAdminPolicy"
  description = "Policy for full Security Group administration"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSecurityGroupRules",
          "ec2:DescribeSecurityGroupReferences",
          "ec2:DescribeStaleSecurityGroups",
          "ec2:CreateSecurityGroup",
          "ec2:DeleteSecurityGroup",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:UpdateSecurityGroupRuleDescriptionsIngress",
          "ec2:UpdateSecurityGroupRuleDescriptionsEgress",
          "ec2:ModifySecurityGroupRules",
          "ec2:CreateTags",
          "ec2:DeleteTags"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach Security Group Admin Policy
resource "aws_iam_user_policy_attachment" "sg_admin" {
  user       = aws_iam_user.git_user.name
  policy_arn = aws_iam_policy.sg_admin.arn
}

# Optional: Create access keys for programmatic access
resource "aws_iam_access_key" "git_user_key" {
  user = aws_iam_user.git_user.name
}








