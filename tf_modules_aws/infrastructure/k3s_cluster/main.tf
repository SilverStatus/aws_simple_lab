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

module "ec2" {
  source                  = "../../modules/ec2"
  region                  = var.region
  vpc_id                  = module.vpc.aws_vpc
  vpc_cidr_block          = module.vpc.vpc_cidr_block
  create_spot_instances   = "true"
  instance_type_on_spot   = var.instance_type_on_spot
  ami_selection           = var.ami_selection
  count_spot_instances    = var.count_spot_instances
  create_on_demand_instances = "false"
  instance_type_on_demand = var.instance_type_on_demand
  count_on_demand_instances = var.count_on_demand_instances

  environment  = var.environment
  application  = var.application
  owner        = var.owner
  cost_center  = var.cost_center
  tags         = var.tags

  
}


