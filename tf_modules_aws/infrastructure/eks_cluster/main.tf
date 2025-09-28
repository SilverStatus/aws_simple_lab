provider "aws" {
  region = var.region
}

module "vpc" {
  source         = "../../modules/vpc"
  region         = var.region
  vpc_id         = var.vpc_id
  vpc_cidr_block = var.vpc_cidr_block

  environment  = var.environment
  application  = var.application
  owner        = var.owner
  cost_center  = var.cost_center
  tags         = var.tags
  
}

module "iam" {
  source         = "../../modules/iam"
  cluster_name   = var.cluster_name
}

module "eks_cluster" {
  source         = "../../modules/eks"
  cluster_name   = var.cluster_name
  role_arn       = module.iam.eks_cluster_iam_role_arn
  eks_version    = var.eks_version
  subnet_ids     = module.vpc.public_subnet_ids
  
}

module "eks_asg" {
  source         = "../../modules/eks_asg" 
  aws_eks_cluster_name = module.eks_cluster.cluster_name
  subnet_ids     = module.vpc.public_subnet_ids 
  node_role_arn  = module.iam.eks_node_group_arn
  
  # Spot instance configuration
  desired_nodes_spot = 2
  max_nodes_spot     = 3
  min_nodes_spot     = 1
  node_instance_type_spot = "t3.medium"
}