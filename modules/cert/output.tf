output "arn" {
  value = length(aws_acm_certificate.cert) > 0 ? aws_acm_certificate.cert[0].arn : null
  description = "ARN of the acm certificate if there is one that can be returned"
}