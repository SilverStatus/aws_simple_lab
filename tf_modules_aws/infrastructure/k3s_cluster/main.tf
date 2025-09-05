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
