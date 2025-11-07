output "cname_target" {
  value       = module.lb.dns_name
  description = "DNS CNAME of the load balancer to reach in order to talk to the service"
}