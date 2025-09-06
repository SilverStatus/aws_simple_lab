output "aws_lb" {
    value = aws_alb.k3s_lb
}

output "k3s_target_group_arn" {
  value = aws_lb_target_group.k3s_lb_tg.arn
}

output "k3s_lb_arn" {
  value = aws_lb.k3s_lb.arn
}