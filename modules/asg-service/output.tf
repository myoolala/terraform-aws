output "cname_target" {
  value       = var.lb != null ? module.lb[0].dns_name : null
  description = "DNS CNAME target to use to reach the service"
}