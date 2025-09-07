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

#variables for vpc
variable "vpc_id" {
  description = "The ID of the VPC where resources will be deployed"
  type        = string
}


#variable for alb
variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

#ec2 variable as reference
variable "k3s_instance_spot_ids" {
  description = "List of instance IDs for the spot instances"
  type        = list(string)
}

variable "k3s_target_group_arn" {
  description = "ARN of the target group"
  type        = string
}


