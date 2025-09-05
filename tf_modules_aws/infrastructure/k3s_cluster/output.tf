output "aws_vpc" {
    value = module.vpc.vpc_id
}

output "aws_subnet" {
    value = module.vpc.public_subnet_ids
}

output "route_table_id" {
    value = module.vpc.public_route_table_id
}