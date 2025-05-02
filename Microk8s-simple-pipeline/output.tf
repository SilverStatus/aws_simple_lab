output "aws_availability_zones" {
    value = data.aws_availability_zones.available.names
}
