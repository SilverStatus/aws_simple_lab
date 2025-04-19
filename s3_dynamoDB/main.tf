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
