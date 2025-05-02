output "aws_availability_zones" {
    value = data.aws_availability_zones.available.names
}

output "aws_vpc" {
    value = aws_vpc.microk8s-vpc.id
}

output "aws_subnet" {
    value = aws_subnet.public_subnet[*].id
}
