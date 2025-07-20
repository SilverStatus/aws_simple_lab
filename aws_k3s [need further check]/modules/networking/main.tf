# Create the main VPC with DNS support enabled
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "devops-vpc"
    ManagedBy = "Terraform"
    Environment = "Development"
  } 
}

# Create internet gateway and attach it to the VPC
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
    tags = {
        Name = "devops-igw"
        ManagedBy = "Terraform"
        Environment = "Development"
    }               
}

# Get available availability zones in the region
data "aws_availability_zones" "available" {
  state = "available"   # Only consider available AZs
}

# Create public subnets in each availability zone
resource "aws_subnet" "public_subnet" {
  count = length(data.aws_availability_zones.available.names)
  vpc_id = aws_vpc.main.id
  cidr_block = cidrsubnet(var.vpc_cidr_block, 8, count.index) # /24 subnets
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true # Auto-assign public IPs
    tags = {
        Name = "devops-public-subnet-${count.index}"
        ManagedBy = "Terraform"
        Environment = "Development"
    }
}

# Create a route table for the public subnet
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id      
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main.id
    }
    tags = {
        Name = "devops-public-route-table"
        ManagedBy = "Terraform"
        Environment = "Development"
    }
}
# Associate the route table with the public subnet
resource "aws_route_table_association" "public_subnet_association" {
  count = length(data.aws_availability_zones.available.names)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
} 

