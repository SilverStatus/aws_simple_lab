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
  vpc_id                  = module.vpc.vpc_id
  vpc_cidr_block          = module.vpc.vpc_cidr_block
  public_subnet_ids       = module.vpc.public_subnet_ids

  k3s_instance_spot_ids = module.ec2.k3_instance_spot_ids
  k3s_target_group_arn  = module.alb.k3s_target_group_arn

  create_spot_instances   = "true"
  instance_type_on_spot   = var.instance_type_on_spot
  ami_selection           = var.ami_selection
  count_spot_instances    = var.count_spot_instances
  create_on_demand_instances  = "false"
  # instance_type_on_demand     = var.instance_type_on_demand
  # count_on_demand_instances   = var.count_on_demand_instances

  environment  = var.environment
  application  = var.application
  owner        = var.owner
  cost_center  = var.cost_center
  tags         = var.tags

  
}

module "alb" {
  source = "../../modules/alb"
  vpc_id = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids

  # Pass instance IDs from ec2 module
  k3s_instance_spot_ids = module.ec2.k3_instance_spot_ids

  # Pass the target group ARN from the alb module
  k3s_target_group_arn = module.alb.k3s_target_group_arn  # Use the output from the alb module

  environment = var.environment
  application = var.application
  owner       = var.owner
  cost_center = var.cost_center
  tags        = var.tags
  
}


