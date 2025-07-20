module "networking" {
    source = "./modules/networking"
    vpc_cidr_block = var.vpc_cidr_block
}

module "compute" {
    source = "./modules/compute"
    project_name = var.project_name
    instance_type = var.instance_type
    key_name = var.key_name
    vpc_id = module.networking.vpc_id  # VPC ID from networking module
    public_subnet_ids = module.networking.public_subnet_ids # Subnet IDs
}
