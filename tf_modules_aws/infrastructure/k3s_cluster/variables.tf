#common variables
variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where resources will be deployed"
  type        = string
}
variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string  
}

#identification and tagging variables
variable "environment" {
  description = "The environment for the resources (e.g., dev, prod)"
  type        = string
}
variable "application" {
  description = "The application name for tagging purposes"
  type        = string
}
variable "owner" {
  description = "The owner of the resources for tagging purposes"
  type        = string
}
variable "cost_center" {
  description = "The cost center for tagging purposes"
  type        = string  
}
variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

