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
}

module "eks_cluster" {
  source         = "../../modules/eks"
  cluster_name   = var.cluster_name
  role_arn       = module.iam.eks_cluster_iam_role
  eks_version    = var.eks_version
  subnet_ids     = module.vpc.public_subnet_ids
  
}