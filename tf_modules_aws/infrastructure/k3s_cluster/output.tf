output "aws_availability_zones" {
    value = data.aws_availability_zones.azs.names
}

output "aws_vpc" {
    value = module.vpc.main_vpc.id
}       

output "aws_subnet" {
    value = module.vpc.public_subnet[*].id
}

output "route_table_id" {
    value = module.vpc.public_route_table.id
}