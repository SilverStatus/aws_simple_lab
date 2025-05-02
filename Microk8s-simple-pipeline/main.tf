# Fetch available AZs in the current region (makes code region-agnostic)
data "aws_availability_zones" "available" {
  state = "available"  # Only consider AZs that can provision resources
}

resource "aws_vpc" "microk8s-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "${var.project_name}-vpc"
    Environment = "Terraform"
    Project = "${var.project_name}"
  }
}

resource "aws_subnet" "public_subnet" {
  count = length(data.aws_availability_zones.available.names)
  vpc_id = aws_vpc.microk8s-vpc.id
  cidr_block = cidrsubnet(aws_vpc.microk8s-vpc.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project_name}-public-subnet-${count.index}"
    Environment = "Terraform"
    Project = "${var.project_name}"
  }
  
}
