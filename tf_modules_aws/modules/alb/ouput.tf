output "aws_lb" {
    value = aws_alb.k3s_lb
}

output "k3s_target_group_arn" {
  value = aws_lb_target_group.k3s_lb_tg.arn
}

output "k3s_lb_arn" {
  value = aws_alb.k3s_lb.arn
}

# set ouput for alb sg
output "alb_sg_1" {
  value = aws_security_group.alb_sg.id 
}
