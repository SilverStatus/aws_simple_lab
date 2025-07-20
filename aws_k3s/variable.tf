variable "region" {
  description = "AWS region to deploy the K3s cluster"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "k3s-cluster"
} 

variable "instance_type" {
  description = "EC2 instance type for the compute nodes"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of the SSH key pair to use for the instances"
  type        = string
  default     = "test"
}
