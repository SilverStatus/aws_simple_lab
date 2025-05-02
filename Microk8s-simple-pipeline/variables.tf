variable "project_name" {
  description = "The name of the current project we're working with"
  type        = string
  default     = "mickrok8s-project"
}

variable "ami_selection" {
    description = "The AMI to use for the EC2 instance"
    type        = string
    default     = "ami-084568db4383264d4"
}

variable "instance_type" {
    description = "The type of instance to use"
    type        = string
    default     = "t2.micro"
}
