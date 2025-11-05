output "cname_target" {
  value = module.lb.dns_name
  description = "DNS CNAME target to use to reach the service"
}