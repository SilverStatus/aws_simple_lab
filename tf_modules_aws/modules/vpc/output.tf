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

# Explanation of the Fix
# 1. for subnet in aws_subnet.public_subnet: Iterates over all public subnets.
# 2. subnet.availability_zone => subnet.id: Creates a map where the key is the availability_zone and the value is the id of the subnet.
# 3. tomap: Ensures the result is a valid map.
# 4. No if Condition: The for expression automatically overwrites duplicate keys (i.e., if multiple subnets exist in the same Availability Zone, only the last one is kept).

output "public_subnet_ids_by_az" {
  value = tomap({
    for subnet in aws_subnet.public_subnet :
    subnet.availability_zone => subnet.id
  })
}