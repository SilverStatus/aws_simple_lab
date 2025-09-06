output "vpc_id" {
    value = aws_vpc.main_vpc.id
}

output "public_subnet_ids" {
    value = aws_subnet.public_subnet[*].id
}

output "route_table_id" {
    value = aws_route_table.public_route_table.id
}

output "vpc_cidr_block" {
    value = aws_vpc.main_vpc
}


