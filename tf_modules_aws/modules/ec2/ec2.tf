#Create security group for EC2 instances
resource "aws_security_group" "instance_sg" {
    name = "${var.environment}-${var.application}-instance-sg"
    description = "Security group for EC2 instances"
    vpc_id = var.vpc_id

    # Allow inbound access to ec2 intances from within the same security group
    ingress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"  # All protocols
      self        = true  # Critical: Allows members of this SG to talk to each other
    }

    # Allow access to all port from specified CIDR blocks
    ingress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"  # All protocols
        cidr_blocks = ["118.99.102.130/32"]
    }

    # Allow all outbound traffic
    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"  # All protocols
      cidr_blocks = ["0.0.0.0/0"]
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

# Create EC2 instances
resource "aws_instance" "k3_instance_spot" {
    for_each        = var.create_spot_instances ? toset([for i in range(var.count_spot_instances) : tostring(i)]) : toset([]) #create instances only if create_spot_instances is true
    ami             = var.ami_selection
    instance_type   = var.instance_type_on_spot
    #subnet_id      = element(module.vpc.public_subnet_ids, 0)  # Use the first public subnet from the VPC module
    subnet_id       = var.public_subnet_ids[tonumber(each.key)]
    key_name        = "test"  
    security_groups = [aws_security_group.instance_sg.name]
    associate_public_ip_address = true

    instance_market_options {
    market_type = "spot"
    spot_options {
      max_price = "0.02"
      spot_instance_type = "persistent"
      instance_interruption_behavior = "stop"
    }
  }

    tags = merge(
    {
      Name        = "${var.environment}-${var.application}-instance",
      Environment = var.environment,
      Owner       = var.owner,
      CostCenter  = var.cost_center,
      Application = var.application
    },
    var.tags
  )
}

resource "aws_instance" "k3s_instance_on_demand" {
    for_each          = var.create_on_demand_instances ? toset([for i in range(var.count_on_demand_instances) : tostring(i)]) : toset([]) #create instances only if create_spot_instances is true
    ami               = var.ami_selection  
    instance_type     = var.instance_type_on_demand
    subnet_id         = var.public_subnet_ids[tonumber(each.key)]
    vpc_security_group_ids = [aws_security_group.instance_sg.id]
    associate_public_ip_address = true
    key_name = "test"
    lifecycle {
      create_before_destroy = true
    }
    tags = merge(
      {
        Name        = "${var.environment}-${var.application}-instance",
        Environment = var.environment,
        Owner       = var.owner,
        CostCenter  = var.cost_center,
        Application = var.application
      },
      var.tags
    )
  
}

