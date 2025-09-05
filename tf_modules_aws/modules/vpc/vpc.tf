data "aws_availability_zones" "azs" {
  state = "available"  
}

resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_cidr_block

  tags = merge(
    {
      Name        = "${var.environment}-${var.application}-vpc",
      Environment = var.environment,
      Owner       = var.owner,
      CostCenter  = var.cost_center,
      Application = var.application
    },
    var.tags
  )
  
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 8, 0)
  availability_zone       = data.aws_availability_zones.azs.names[0]
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name        = "${var.environment}-${var.application}-public-subnet",
      Environment = var.environment,
      Owner       = var.owner,
      CostCenter  = var.cost_center,
      Application = var.application
    },
    var.tags
  )
}
# create an internet gateway and attach it to the VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = merge(
    {
      Name        = "${var.environment}-${var.application}-igw",
      Environment = var.environment,
      Owner       = var.owner,
      CostCenter  = var.cost_center,
      Application = var.application
    },
    var.tags
  )
  
}

# create a route table for the public subnet
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
    }
  tags = merge(
    {
      Name        = "${var.environment}-${var.application}-public-rt",
      Environment = var.environment,
      Owner       = var.owner,
      CostCenter  = var.cost_center,
      Application = var.application
    },
    var.tags
  )  
}

# associate the public subnet with the public route table
resource "aws_route_table_association" "public_subnet_association" {
  count = length(data.aws_availability_zones.azs.names)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}