# Fetch available AZs in the current region (makes code region-agnostic)
data "aws_availability_zones" "available" {
  state = "available"  # Only consider AZs that can provision resources
}

resource "aws_vpc" "k3s-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "${var.project_name}-vpc"
    ManagedBy = "Terraform"
    Project = "${var.project_name}"
  }
}

resource "aws_subnet" "public_subnet" {
  count = length(data.aws_availability_zones.available.names)
  vpc_id = aws_vpc.k3s-vpc.id
  cidr_block = cidrsubnet(aws_vpc.k3s-vpc.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project_name}-public-subnet-${count.index}"
    ManagedBy = "Terraform"
    Project = "${var.project_name}"
  }
}

# Create a security group for the instances
resource "aws_security_group" "instance_sg" {
  name        = "multi-az-instance-sg"
  description = "Security group for multi-AZ instance group"
  vpc_id      = aws_vpc.k3s-vpc.id

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
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # All protocols
    cidr_blocks = ["118.99.102.130/32"]
  }

  # Allow traffic on port 30000 (for n8n) from alb sg
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # All protocols
    security_groups = [aws_security_group.alb_sg.id]  # Allow traffic from ALB security group
  }

  # # Allow HTTP access
  # ingress {
  #   from_port   = 80
  #   to_port     = 80
  #   protocol    = "tcp"
  #   cidr_blocks = [aws_security_group.alb_sg.id] # Allow traffic from ALB security group
  # }

  # # Allow HTTPS access
  # ingress {
  #   from_port   = 443
  #   to_port     = 443
  #   protocol    = "tcp"
  #   cidr_blocks = [aws_security_group.alb_sg.id] # Allow traffic from ALB security group
  # }

  # # Allow traffic on port 81 (nginx proxy manager) from alb
  # ingress {
  #   from_port   = 81
  #   to_port     = 81
  #   protocol    = "tcp"
  #   security_groups = [aws_security_group.alb_sg.id]  # Allow traffic from ALB security group
  # }

  # Uncomment the following block to allow traffic on port 30000 from anywhere
  # Allow traffic on port 30000 (for n8n) from anywhere to ec2 instances
  # ingress {
  #   from_port   = 30000
  #   to_port     = 30000
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # } 

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
    tags = {
        Name        = "${var.project_name}-instance-sg"
        ManagedBy = "Terraform"
        Project     = "${var.project_name}"
    }
}


# Create EC2 instances on spot for k3s
resource "aws_instance" "k3s_instance_spot" {
  count             = 1
  ami               = var.ami_selection  
  instance_type     = var.instance_type_on_spot
  subnet_id         = aws_subnet.public_subnet[count.index].id
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  associate_public_ip_address = true
  key_name = "test"
  #user_data = filebase64("${path.module}/scripts/control-plane.sh master")
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
    Name        = "${var.project_name}-instance-${count.index}"
    ManagedBy = "Terraform"
    Project     = "${var.project_name}"
  }
  
}

resource "aws_instance" "bastion_instance" {
  count             = 1
  ami               = var.ami_selection  
  instance_type     = var.instance_type_on_spot_bastion
  subnet_id         = aws_subnet.public_subnet[count.index].id
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  associate_public_ip_address = true
  key_name = "test"
  #user_data = filebase64("${path.module}/scripts/control-plane.sh master")
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
    Name        = "${var.project_name}-bastion-instance-${count.index}"
    ManagedBy = "Terraform"
    Project     = "${var.project_name}"
  }
  
}

# Create internet gateway and attach it to the VPC
resource "aws_internet_gateway" "k3s-igw" {
  vpc_id = aws_vpc.k3s-vpc.id
  tags = {
    Name        = "${var.project_name}-igw"
    ManagedBy = "Terraform"
    Project     = "${var.project_name}"
  }
}
# Create a route table for the public subnet
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.k3s-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.k3s-igw.id
    }
    tags = {
        Name        = "${var.project_name}-public-route-table"
        ManagedBy = "Terraform"
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
  vpc_id      = aws_vpc.k3s-vpc.id

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

  # ingress {
  #   from_port   = 30000
  #   to_port     = 30000
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-alb-sg"
    ManagedBy = "Terraform"
    Project     = "${var.project_name}"
  }

}

# Create ALB
resource "aws_lb" "k3s_lb" {
  name = "k3s-lb"
  internal = false 
  load_balancer_type = "application"
  security_groups = [aws_security_group.alb_sg.id]
  subnets = aws_subnet.public_subnet[*].id
  enable_deletion_protection = false

  tags = {
    ManagedBy = "Terraform"
  }
  
}

# Create target group for the ALB for enable access to nginx proxy manager admin
resource "aws_lb_target_group" "k3s_tg" {
  name     = "${var.project_name}-target-group"
  port     = 30081  
  protocol = "HTTP"
  vpc_id   = aws_vpc.k3s-vpc.id

  protocol_version = "HTTP2" 
  target_type = "instance" # Use instance type for direct EC2 instance targets
  

  health_check {
    path                = "/nginx"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
  
}


resource "aws_lb_target_group_attachment" "k3s_tg_attachment_spot" {
  count = length(aws_instance.k3s_instance_spot) 
  target_group_arn = aws_lb_target_group.k3s_tg.arn
  target_id        = aws_instance.k3s_instance_spot[count.index].id
  port             =  30081 #30000
}

# Create listener for the ALB
resource "aws_lb_listener" "k3s_listener" {
  load_balancer_arn = aws_lb.k3s_lb.arn
  port              = 30081
  protocol          = "HTTP"
  depends_on = [ aws_lb_target_group.k3s_tg ]

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.k3s_tg.arn
  }
}

# enable terraform remote backend and state locking
terraform {
  backend "s3" {
    bucket         = "terraform-101001"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    use_lockfile = true
  }
}


