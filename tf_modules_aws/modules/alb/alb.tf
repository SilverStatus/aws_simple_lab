resource "aws_security_group" "alb_sg" {
    name = "${var.environment}-${var.application}-alb-sg"
    description = "security group for alb"
    vpc_id = var.vpc_id

    #allow http access to alb
    ingress {
       from_port   = 80
       to_port     = 80
       protocol    = "tcp"
       cidr_blocks = ["0.0.0.0/0"]
    }

    #allow https access to alb
    ingress {
       from_port   = 443
       to_port     = 443
       protocol    = "tcp"
       cidr_blocks = ["0.0.0.0/0"]
    }

    #allow all traffic from alb 
    egress {
       from_port   = 0
       to_port     = 0
       protocol    = "-1"
       cidr_blocks = ["0.0.0.0/0"]
    }

    tags = merge(
    {
      Name        = "${var.environment}-${var.application}-alb-sg",
      Environment = var.environment,
      Owner       = var.owner,
      CostCenter  = var.cost_center,
      Application = var.application
    },
    var.tags
  )
}

#create alb
resource "aws_alb" "k3s_lb" {
    name                = "${var.application}-lb"
    internal            = false
    load_balancer_type  = "application"
    security_groups     = [aws_security_group.alb_sg.id]
    subnets             = var.public_subnet_ids
    enable_deletion_protection = false

    tags = merge(
    {
      Name        = "${var.environment}-${var.application}-alb",
      Environment = var.environment,
      Owner       = var.owner,
      CostCenter  = var.cost_center,
      Application = var.application
    },
    var.tags
  )

}

#create alb target group
resource "aws_lb_target_group" "k3s_lb_tg" {
    name = "${var.application}-target-group"
    port = 80
    protocol = HTTP
    vpc_id = var.vpc_id
    target_type = "instance"

    health_check {
      path                = "/"
      interval            = 30
      timeout             = 5
      healthy_threshold   = 2
      unhealthy_threshold = 2
      matcher             = "200,302" # Adjusted to match the expected response codes
    }

    tags = merge(
    {
      Name        = "${var.environment}-${var.application}-target-group",
      Environment = var.environment,
      Owner       = var.owner,
      CostCenter  = var.cost_center,
      Application = var.application
    },
    var.tags
  )

}

#create target group attachment
resource "aws_lb_target_group_attachment" "k3s_tg_attachment_spot" {
    count               = length(aws_instance.k3s_instance_spot) 
    target_group_arn    = aws_lb_target_group.k3s_tg.arn
    target_id           = aws_instance.k3_instance_spot_ids
    port                = 80
}

#create listener for target group
resource "aws_lb_listener" "k3s_listener" {
    load_balancer_arn = aws_lb.k3s_lb.arn
    port              = 80
    protocol          = "HTTP"
    depends_on        = [ aws_lb_target_group.k3s_lb_tg ]

    default_action {
      type             = "forward"
      target_group_arn = aws_lb_target_group.k3s_lb_tg.arn
    }
}