output "sg_id" {
  value = var.type != "network" ? aws_security_group.lb[0].id : null
}

output "tg_arns" {
  value = aws_lb_target_group.forwarder[*].arn
}

output "dns_name" {
  value = aws_lb.ingress.dns_name
}