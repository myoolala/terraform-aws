output "cname_target" {
    value = aws_lb.ingress.dns_name
}