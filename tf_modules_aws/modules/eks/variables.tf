#eks cluster variables
variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = "eks-cluster-trial"
}

variable "role_arn" {
  description = "The ARN of the IAM role to use for the EKS cluster"
  type        = string
  default     = aws_iam_role.eks_cluster.arn #fill with eks cluster role arn after create iam module
}

variable "eks_version" {
  description = "The version of EKS to use"
  type        = string
  default     = "1.30"
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

#iam role eks
variable "eks_cluster_iam_role" {
  description = "The ARN of the IAM role to use for the EKS cluster"
  type        = string
  default     = "" #fill with eks cluster role arn after create iam module
}
