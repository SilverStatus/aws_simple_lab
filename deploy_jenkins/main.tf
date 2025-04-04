
# create vpc for jenkins
resource "aws_vpc" "jenkins-env" {
    cidr_block = "110.137.50.0/24"
}

# create subnet for jenkins
resource "aws_subnet" "jenkins-subnet-1" {
    vpc_id = aws_vpc.jenkins-env.id
    cidr_block = "110.137.50.0/25"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true
    tags = {
        Name = "${var.project_name}-jenkins-subnet-1"
    }
}

resource "aws_subnet" "jenkins-subnet-2" {
    vpc_id = aws_vpc.jenkins-env.id
    cidr_block = "110.137.50.128/25"
    availability_zone = "us-east-1b"
    map_public_ip_on_launch = true
    tags = {
        Name = "${var.project_name}-jenkins-subnet-2"
    }
}

# create internet gateway and attach it to the VPC
resource "aws_internet_gateway" "jenkins-igw" {
    vpc_id = aws_vpc.jenkins-env.id
    tags = {
        Name = "${var.project_name}-jenkins-igw"
    }
}

resource "aws_route_table" "jenkins-route-table" {
    vpc_id = aws_vpc.jenkins-env.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.jenkins-igw.id
    }
    tags = {
        Name = "${var.project_name}-jenkins-route-table"
    }
}

resource "aws_route_table_association" "jenkins-route" {
    subnet_id = aws_subnet.jenkins-subnet-1.id
    route_table_id = aws_route_table.jenkins-route-table.id
}

# create security group that allows traffic from the internet
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-security-group"
  description = "Allow SSH, HTTP/HTTPS, and outbound traffic"
  vpc_id      = aws_vpc.jenkins-env.id  

  # SSH access from your public IP only
  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["36.82.121.165/32"]  
  }

  # Jenkins Web UI (HTTP)
  ingress {
    description = "HTTP for Jenkins UI"
    from_port   = 8080  # Default Jenkins port
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["36.82.121.165/32"]  # Restrict to your IP or office IP range
  }

  # Optional: HTTP 90 
  ingress {
    description = "HTTP for Jenkins UI"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Full outbound access (for Jenkins to download plugins, Terraform, etc.)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-sg"
  }
}

resource "aws_instance" "ec2" {
   ami = var.ami_selection
   instance_type = "t2.micro"
   subnet_id = aws_subnet.jenkins-subnet-1.id
   key_name = "test"

   # attach bash script to the instance
   user_data = filebase64("install_jenkins.sh")

   # Associate the security group with the instance
   vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
   tags = {
       Name = "jenkins-server"  
   }
}

# create s3 bucket for jenkins
resource "aws_s3_bucket" "terraform-jenkins" {
    bucket = "terraform-jenkins-101001"
    force_destroy = "true" # Allow force destroy for testing purposes 
    tags = {
        Name = "terraform-jenkins"
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