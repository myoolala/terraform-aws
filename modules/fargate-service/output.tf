output "cname_target" {
  value       = var.lb != null ? module.lb.dns_name : null
  description = "DNS CNAME of the load balancer to reach in order to talk to the service"
}