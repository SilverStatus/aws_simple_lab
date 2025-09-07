#common vpc variables
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
}
variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

#EC2 specific variables

variable "instance_type_on_spot" {
  description = "The type of EC2 instance to create"
  type        = string
  default     = "t3.small"
}

variable "instance_type_on_demand" {
  description = "The type of EC2 instance to create"
  type        = string
  default     = "t3.micro" 
}

variable "ami_selection" {
  description = "The AMI ID to use for the EC2 instance"
  type        = string
  default     = "ami-084568db4383264d4"  # Ubuntu 22.04 AMI (64-bit, non-ARM)
}

variable "count_spot_instances" {
  description = "Number of spot instances to create"
  type        = number
  default     = 2  
}

variable "create_spot_instances" {
  description = "Whether to create spot instances"
  type        = bool
  default     = true
}

variable "count_on_demand_instances" {
  description = "Number to create on demand instances"
  type = number
  default = 2
}

variable "create_on_demand_instances" {
  description = "whether to create on-demand instances"
  type = bool
  default = true
}
