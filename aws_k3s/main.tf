module "networking" {
    source = "./modules/networking"
    vpc_cidr_block = var.vpc_cidr_block
    region = var.region
}
