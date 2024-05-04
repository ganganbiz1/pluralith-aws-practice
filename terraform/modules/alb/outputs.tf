output "lb_target_group_arn" {
  value = aws_lb_target_group.main.arn
}

output "aws_lb_listener_rule" {
  value = aws_lb_listener_rule.main
}

output "aws_lb_id" {
  value = aws_lb.main.id
}

output "aws_lb_dns_name" {
  value = aws_lb.main.dns_name
}