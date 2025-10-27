output "arn" {
  value = length(aws_acm_certificate.cert) > 0 ? aws_acm_certificate.cert[0].arn : null
}