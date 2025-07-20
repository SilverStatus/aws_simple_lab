module "networking" {
    source = "../networking"
    region = var.region
    vpc_cidr = var.vpc_cidr
    project_name = var.project_name
}
