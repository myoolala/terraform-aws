output "sg_id" {
  value       = var.type != "network" ? aws_security_group.lb[0].id : null
  description = "Security Group ID if one was created"
}

output "tg_arns" {
  value       = aws_lb_target_group.forwarder[*].arn
  description = "List of Target Group ARNs for the load balancer"
}

output "dns_name" {
  value       = aws_lb.ingress.dns_name
  description = "DNS CNAME for the load balancer"
}

output "lb_arn" {
  value       = aws_lb.ingress.arn
  description = "ARN for the created load balancer"
}

output "listener_arn" {
  value       = aws_lb_listener.this[*].arn
  description = "ARN for the created load balancer listener"
}

output "logs_bucket_name" {
  value       = local.create_app_log_bucket ? module.application_logs_bucket[0].id : null
  description = "If an application logs bucket was created, what is the name"
}

output "logs_bucket_arn" {
  value       = local.create_app_log_bucket ? module.application_logs_bucket[0].arn : null
  description = "If an application logs bucket was created, what is the arn"
}

output "logs_bucket_prefix" {
  value       = local.create_app_log_bucket ? local.bucket_prefix : null
  description = "If an application logs bucket was created, what is the prefix for logs"
}