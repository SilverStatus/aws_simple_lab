# Creating our Week 21 VPC
resource "aws_vpc" "matts-week-21" {
  cidr_block = "10.0.0.0/16"
}

# Creating our two subnets
resource "aws_subnet" "subnet-1" {
  vpc_id     = aws_vpc.matts-week-21.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project_name}-subnet-1"
  }
}

resource "aws_subnet" "subnet-2" {
  vpc_id     = aws_vpc.matts-week-21.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project_name}-subnet-2"
  }
}

# Creating our internet gateway and attach it to the VPC
resource "aws_internet_gateway" "matts-week-21-igw" {
  vpc_id = aws_vpc.matts-week-21.id
  tags = {
    Name = "${var.project_name}-igw"
  }
}

resource "aws_route_table" "matts-week-21-rt" {
  vpc_id = aws_vpc.matts-week-21.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.matts-week-21-igw.id
  }
  tags = {
    Name = "${var.project_name}-route-table"
  }
}

resource "aws_route_table_association" "matts-week-21-awsrta" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.matts-week-21-rt.id
}

# Creating our security group that allows traffic from the internet
resource "aws_security_group" "allow-tls" {
  name        = "allow-tls"
  description = "Allow TLS inbound traffic from the internet"
  vpc_id      = aws_vpc.matts-week-21.id

  ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.matts-week-21.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow-tls"
  }
}

# Firewall configuration for the our instances
resource "aws_security_group_rule" "matts-week-21-http-inbound" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.allow-tls.id
}

# Creating our launch configuration with user data to launch an Apache web server
resource "aws_launch_template" "matts-week21-lc" {
  name_prefix          = "${var.project_name}-lc"
  image_id             = "ami-08b5b3a93ed654d19"
  instance_type        = "t2.micro"
  user_data            = filebase64("apache_httpd.sh")
  network_interfaces {
    security_groups      = [aws_security_group.allow-tls.id]
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Creating our Auto Scaling group
resource "aws_autoscaling_group" "matts-week21-asg" {
  name                 = "${var.project_name}-asg"

  desired_capacity     = 2
  max_size             = 5
  min_size             = 2
  health_check_type    = "EC2"
  vpc_zone_identifier  = [aws_subnet.subnet-1.id, aws_subnet.subnet-2.id]

  launch_configuration = aws_launch_template.matts-week21-lc.id
}

# Creating our Application Load Balancer target group
resource "aws_lb_target_group" "matts-week21-lbtg" {
  name     = "${var.project_name}-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.matts-week-21.id
}
