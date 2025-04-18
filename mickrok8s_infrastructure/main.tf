
# create vpc for microk8s
resource "aws_vpc" "microk8s-env" {
    cidr_block = "110.137.50.0/24"
    tags = {
      Name = "${var.project_name}-microk8s-env"
      Environment = "Terraform"
      Project = "${var.project_name}"
    }
}

# create subnet for microk8s
resource "aws_subnet" "microk8s-subnet-1" {
    vpc_id = aws_vpc.microk8s-env.id
    cidr_block = "110.137.50.0/25"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true
    tags = {
        Name = "${var.project_name}-microk8s-subnet-1"
    }
}

resource "aws_subnet" "microk8s-subnet-2" {
    vpc_id = aws_vpc.microk8s-env.id
    cidr_block = "110.137.50.128/25"
    availability_zone = "us-east-1b"
    map_public_ip_on_launch = true
    tags = {
        Name = "${var.project_name}-microk8s-subnet-2"
    }
}

# create internet gateway and attach it to the VPC
resource "aws_internet_gateway" "microk8s-igw" {
    vpc_id = aws_vpc.microk8s-env.id
    tags = {
        Name = "${var.project_name}-microk8s-igw"
    }
}

resource "aws_route_table" "microk8s-route-table" {
    vpc_id = aws_vpc.microk8s-env.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.microk8s-igw.id
    }
    tags = {
        Name = "${var.project_name}-microk8s-route-table"
    }
}

resource "aws_route_table_association" "microk8s-route" {
    subnet_id = aws_subnet.microk8s-subnet-1.id
    route_table_id = aws_route_table.microk8s-route-table.id
}

# create security group that allows traffic from the internet
resource "aws_security_group" "microk8s_sg" {
  name        = "microk8s-security-group"
  description = "Allow SSH, HTTP/HTTPS, and outbound traffic"
  vpc_id      = aws_vpc.microk8s-env.id  

  # SSH access from your public IP only
  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["118.99.115.149/32"]  
  }

  # microk8s Web UI (HTTP)
  ingress {
    description = "HTTP for microk8s UI"
    from_port   = 8080  # Default microk8s port
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["36.82.121.165/32"]  # Restrict to your IP or office IP range
  }

  # Optional: HTTP 80 
  ingress {
    description = "HTTP for microk8s UI"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Full outbound access (for microk8s to download plugins, Terraform, etc.)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "microk8s-sg"
  }
}

# Define the security group for the EC2 Instance
module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.17.1"

  name        = "alb-sg-${var.project_name}"
  description = "Security group for example usage with ALB"
  vpc_id      = aws_vpc.microk8s-env.id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp"]
  egress_rules        = ["all-all"]
}

# define module to create alb
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "8.2.2"

  name = "complete-alb-for-test"

  load_balancer_type = "application"

  vpc_id          = aws_vpc.microk8s-env.id
  security_groups = [module.security_group.security_group_id]
  subnets         = [aws_subnet.microk8s-subnet-1.id, aws_subnet.microk8s-subnet-2.id]

  http_tcp_listeners = [
    # Forward action is default, either when defined or undefined
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
      # action_type        = "forward"
    },
  ]

  http_tcp_listener_rules = [
    {
      http_tcp_listener_index = 0
      priority                = 3
      actions = [{
        type         = "fixed-response"
        content_type = "text/plain"
        status_code  = 200
        message_body = "This is a fixed response"
      }]

      conditions = [{
        http_headers = [{
          http_header_name = "x-Gimme-Fixed-Response"
          values           = ["yes", "please", "right now"]
        }]
      }]
    },
  ]

  target_groups = [
    {
      name_prefix          = "h1"
      backend_protocol     = "HTTP"
      backend_port         = 80
      target_type          = "instance"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }
      protocol_version = "HTTP1"
      tags = {
        InstanceTargetGroupTag = "baz"
      }
    },
  ]

}

resource "aws_launch_configuration" "as_conf" {
  name_prefix   = "terraform-lc-example-"
  image_id      = var.ami_selection
  instance_type = var.instance_type

  security_groups = [aws_security_group.microk8s_sg.id]

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_autoscaling_group" "asg-test" {
  name                 = "terraform-asg-example"
  launch_configuration = aws_launch_configuration.as_conf.name
  vpc_zone_identifier  = [aws_subnet.microk8s-subnet-1.id, aws_subnet.microk8s-subnet-2.id]
  desired_capacity     = 1
  min_size             = 2
  max_size             = 5

  depends_on = [module.alb]

  target_group_arns    =  module.alb.target_group_arns

  tag {
    key                   = "Name"
    value                 = "TF-ALB-ASG-EC2-${var.project_name}"
    propagate_at_launch   = true
  }

  lifecycle {
    create_before_destroy = true
  }
  
}

resource "aws_autoscaling_policy" "example-autoscaling-policy" {
  autoscaling_group_name = aws_autoscaling_group.asg-test.name
  name                   = "example-autoscaling-policy"
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 40.0
    disable_scale_in  = false
  }
}

# create s3 bucket for microk8s
resource "aws_s3_bucket" "terraform-microk8s" {
    bucket = "terraform-microk8s-101001"
    force_destroy = "true" # Allow force destroy for testing purposes 
    tags = {
        Name = "terraform-microk8s"
        description = "terraform S3 bucket"
    }
}

# create dynamodb table for state locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform_locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "terraform_locks"
    Environment = "Terraform"
  }
  
}

# enable terraform remote backend and state locking
# terraform {
#   backend "s3" {
#     bucket         = "terraform-microk8s-101001"
#     key            = "terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "terraform_locks"
#     depends_on = [aws_s3_bucket.terraform-microk8s, aws_dynamodb_table.terraform_locks]
#   }
# }