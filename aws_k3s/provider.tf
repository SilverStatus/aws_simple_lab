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
  region = var.region
}
