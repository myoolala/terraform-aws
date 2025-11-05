output "sg_id" {
  value = var.type != "network" ? aws_security_group.lb[0].id : null
  description = "Security Group ID if one was created"
}

output "tg_arns" {
  value = aws_lb_target_group.forwarder[*].arn
  description = "List of Target Group ARNs for the load balancer"
}

output "dns_name" {
  value = aws_lb.ingress.dns_name
  description = "DNS CNAME for the load balancer"
}

output "lb_arn" {
  value = aws_lb.ingress.arn
  description = "ARN for the created load balancer"
}