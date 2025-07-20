variable "ami_id" {
  description = "The AMI ID to use for the compute instances."
  type        = string
  default = "value"
}

variable "instance_type" {
  description = "The type of instance to use for the compute instances."
  type        = string
  default     = "t2.micro"
}
variable "project_name" {
  description = "The name of the project for tagging resources."
  type        = string
  default     = "DevOps_project"
}
variable "instance_count" {
  description = "The number of instances to create."
  type        = number
  default     = 3
}

variable "key_name" {
  description = "The name of the key pair to use for SSH access to the instances."
  type        = string
  default     = "my-key-pair"
}
