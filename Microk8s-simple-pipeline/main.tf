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
    cidr_blocks = ["118.99.101.99/32"]
  }

  # Allow HTTP access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["118.99.101.99/32"]
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

# Create EC2 instances on demand
resource "aws_instance" "microk8s_instance_on_demand" {
  count             = 2
  ami               = var.ami_selection  
  instance_type     = var.instance_type
  subnet_id         = aws_subnet.public_subnet[count.index].id
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  associate_public_ip_address = true
  key_name = "test"
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo snap install microk8s --classic --channel=1.29/stable
              sudo usermod -a -G microk8s ubuntu
              newgrp microk8s
              while ! command -v microk8s &> /dev/null; do sleep 10; done
              microk8s start
              microk8s status
              EOF
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name        = "${var.project_name}-instanceOD-${count.index}"
    Environment = "Terraform"
    Project     = "${var.project_name}"
  }
  
}

# Create EC2 instances on spot for testing
resource "aws_instance" "microk8s_instance_spot" {
  count             = 1
  ami               = var.ami_selection  
  instance_type     = "t3.small"
  subnet_id         = aws_subnet.public_subnet[count.index].id
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  associate_public_ip_address = true
  key_name = "test"
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo snap install microk8s --classic --channel=1.29/stable
              sudo usermod -a -G microk8s ubuntu
              newgrp microk8s
              while ! command -v microk8s &> /dev/null; do sleep 10; done
              microk8s start
              microk8s status
              EOF
  lifecycle {
    create_before_destroy = true
  }
  instance_market_options {
    market_type = "spot"
    spot_options {
      max_price = "0.02"
      spot_instance_type = "persistent"
      instance_interruption_behavior = "stop"
    }
  }
  tags = {
    Name        = "${var.project_name}-instanceSP-${count.index}"
    Environment = "Terraform"
    Project     = "${var.project_name}"
  }
  
}

# Create internet gateway and attach it to the VPC
resource "aws_internet_gateway" "microk8s-igw" {
  vpc_id = aws_vpc.microk8s-vpc.id
  tags = {
    Name        = "${var.project_name}-igw"
    Environment = "Terraform"
    Project     = "${var.project_name}"
  }
}
# Create a route table for the public subnet
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.microk8s-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.microk8s-igw.id
    }
    tags = {
        Name        = "${var.project_name}-public-route-table"
        Environment = "Terraform"
        Project     = "${var.project_name}"
    }
}
# Associate the route table with the public subnet
resource "aws_route_table_association" "public_subnet_association" {
  count = length(data.aws_availability_zones.available.names)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

# Create security group for the load balancer
resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-alb-sg"
  description = "Security group for ALB allowing HTTP and HTTPS traffic"
  vpc_id      = aws_vpc.microk8s-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

# Create ALB
resource "aws_lb" "microk8s_lb" {
  name = "microk8s-lb"
  internal = false 
  load_balancer_type = "application"
  security_groups = [aws_security_group.alb_sg.id]
  subnets = aws_subnet.public_subnet[*].id
  enable_deletion_protection = false

  tags = {
    Environment = "Development"
  }
  
}

# Create target group for the ALB
resource "aws_lb_target_group" "microk8s_tg" {
  name     = "${var.project_name}-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.microk8s-vpc.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
  
}

# Attach instances to the target group
resource "aws_lb_target_group_attachment" "microk8s_tg_attachment_on_demand" {
  count = length(aws_instance.microk8s_instance_on_demand) 
  target_group_arn = aws_lb_target_group.microk8s_tg.arn
  target_id        = aws_instance.microk8s_instance_on_demand[count.index].id
  port             = 80
}

resource "aws_lb_target_group_attachment" "microk8s_tg_attachment_spot" {
  count = length(aws_instance.microk8s_instance_spot) 
  target_group_arn = aws_lb_target_group.microk8s_tg.arn
  target_id        = aws_instance.microk8s_instance_spot[count.index].id
  port             = 80
}

# Create listener for the ALB
resource "aws_lb_listener" "microk8s_listener" {
  load_balancer_arn = aws_lb.microk8s_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.microk8s_tg.arn
  }
}



