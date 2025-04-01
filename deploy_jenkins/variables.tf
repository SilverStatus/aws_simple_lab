variable "project_name" {
  description = "The name of the current project we're working with"
  type        = string
  default     = "jenkins-aws-tf-project"
}

variable "ami_selection" {
    description = "The AMI to use for the EC2 instance"
    type        = string
    default     = "ami-05b10e08d247fb927"
}