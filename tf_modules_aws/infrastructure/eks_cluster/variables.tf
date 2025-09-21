#common vpc variables
variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1" #test to disable vpc.tfvars
}

variable "vpc_id" {
  description = "The ID of the VPC where resources will be deployed"
  type        = string
  default     = "" #test to disable vpc.tfvars
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC" 
  default = "10.0.0.0/16" #test to disable vpc.tfvars
}

#identification and tagging variables
variable "environment" {
  description = "The environment for the resources (e.g., dev, prod)"
  type        = string
  default     = "Dev"
}
variable "application" {
  description = "The application name for tagging purposes"
  type        = string
  default     = "eks"
}
variable "owner" {
  description = "The owner of the resources for tagging purposes"
  type        = string
  default     = "Infrastructure-Team"
}
variable "cost_center" {
  description = "The cost center for tagging purposes"
  default     = "cloudInfra"
}
variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

#eks cluster variables
variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = ""
}
variable "role_arn" {
  description = "The ARN of the IAM role for the EKS cluster"
  type        = string
  default     = ""
}
variable "eks_version" {
  description = "The version of EKS to deploy"
  type        = string
  default     = ""
}
variable "subnet_ids" {
  description = "A list of subnet IDs to use for the EKS cluster"
  type        = list(string)
  default     = []
}


