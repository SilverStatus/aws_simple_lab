variable "aws_eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string 
  default     = ""
}

#vpc variables
variable "vpc_id" {
  description = "The ID of the VPC to use for the EKS cluster"
  type        = string
  default     = "" #fill with vpc id after create vpc module
}

variable "subnet_ids" {
  description = "The ID of the subnets to use for the EKS cluster"
  type        = list(string)
  default     = [] #fill with vpc id after create vpc module
}

# asg variables
variable "desired_nodes_spot" {
  description = "Desired number of nodes in the node group"
  type        = number
  default     = 1
}

variable "max_nodes_spot" {
  description = "Maximum number of nodes in the node group"
  type        = number
  default     = 2
}

variable "min_nodes_spot" {
  description = "Minimum number of nodes in the node group"
  type        = number
  default     = 0
}

variable "os_instance_type" {
  description = "Operating system instance type to use for the nodes in the node group"
  type        = string
  default     = "ami-084568db4383264d4"  # Ubuntu 22.04 AMI (64-bit, non-ARM)
}

variable "node_instance_type_spot" {
  description = "Instance type to use for the nodes in the node group"
  type        = string
  default     = "t3.small"
}

variable "desired_nodes_on_demand" {
  description = "Desired number of nodes in the node group"
  type        = number
  default     = 1
}

variable "max_nodes_on_demand" {
  description = "Maximum number of nodes in the node group"
  type        = number
  default     = 2
}

variable "min_nodes_on_demand" {
  description = "Minimum number of nodes in the node group"
  type        = number
  default     = 0
}

variable "node_instance_type_on_demand" {
  description = "Instance type to use for the nodes in the node group"
  type        = string
  default     = "t2.micro"
}
