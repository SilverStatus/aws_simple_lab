variable "project_name" {
  description = "The name of the current project we're working with"
  type        = string
  default     = "k8s-aws-tf-project"
}

variable "ami_selection" {
    description = "The AMI to use for the EC2 instance"
    type        = string
    default     = "ami-084568db4383264d4"  # Ubuntu 22.04 AMI (64-bit, non-ARM)
}

variable "instance_type_on_spot" {
    description = "The type of instance to use for spot instances"
    type        = string
    default     = "t3.small"
}

variable "instance_type_on_demand" {
    description = "The type of instance to use for on-demand instances"
    type        = string
    default     = "t2.micro"
  
}