# Security group for EC2 instances
resource "aws_security_group" "ec2" {
    name = "${var.project_name}-ec2-sg"
    description = "Security group for EC2 instances"
    vpc_id = module.networking.aws_vpc.main.id
    ingress {
        description = "Allow SSH access"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = [""] # Replace with your IP or CIDR block
    }
    ingress {
        description = "Allow HTTP access"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "Allow HTTPS access"
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
    tags = {
        Name        = "${var.project_name}-ec2-sg"
        ManagedBy   = "Terraform"
        Environment = "Development"
        Project     = var.project_name
    }
  
}

# Create a EC2 instance with the specified AMI and instance type
resource "aws_instance" "ec2" {
    count         = var.instance_count
    ami           = var.ami_id
    instance_type = var.instance_type
    subnet_id     = aws_subnet.public_subnet[0].id
    vpc_security_group_ids = [aws_security_group.instance_sg.id]
    key_name      = var.key_name
    lifecycle {
        create_before_destroy = true
    }
    instance_market_options {
        market_type = "spot"
        spot_options {
            max_price = "0.05" # Set your maximum price for the spot instance
            spot_instance_type = "persistent"
            instance_interruption_behavior = "stop" 
        }
    }
    
    # Tags for the instance
    tags = {
        Name        = "${var.project_name}-ec2-instance"
        ManagedBy = "Terraform"
        Project     = "${var.project_name}"
    }
}
