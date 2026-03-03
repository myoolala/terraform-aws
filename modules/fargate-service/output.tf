output "cname_target" {
  value       = var.lb != null ? module.lb[0].dns_name : null
  description = "DNS CNAME of the load balancer to reach in order to talk to the service"
}

output "sg_id" {
  value = aws_security_group.service.id
  description = "ID of the created security group if there is one"
}