output "aws_vpc" {
    value = aws_vpc.main_vpc.id
}

output "aws_subnet" {
    value = aws_subnet.public_subnet[*].id
}

output "route_table_id" {
    value = aws_route_table.public_route_table.id
}
