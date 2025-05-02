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

# Create a security group for the instances
resource "aws_security_group" "instance_sg" {
  name        = "multi-az-instance-sg"
  description = "Security group for multi-AZ instance group"
  vpc_id      = aws_vpc.microk8s-vpc.id

  # Allow all inbound traffic from the same security group
    # This is critical for instances to communicate with each other
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # All protocols
    self        = true  # Critical: Allows members of this SG to talk to each other
  }

  # Allow SSH access from anywhere (restrict in production!)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
    tags = {
        Name        = "${var.project_name}-instance-sg"
        Environment = "Terraform"
        Project     = "${var.project_name}"
    }
}

resource "aws_instance" "microk8s_instance" {
  count             = 3
  ami               = var.ami_selection  # Amazon Linux 2 AMI
  instance_type     = var.instance_type
  subnet_id         = aws_subnet.public_subnet[count.index].id
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  associate_public_ip_address = true

  tags = {
    Name        = "${var.project_name}-instance-${count.index}"
    Environment = "Terraform"
    Project     = "${var.project_name}"
  }
  
}


