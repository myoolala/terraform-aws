resource "aws_acm_certificate" "cert" {
  count = var.domain != null ? 1 : 0

  domain_name       = var.domain
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_route53_zone" "cert" {
  count        = var.hosted_zone != null ? 1 : 0
  name         = var.hosted_zone
  private_zone = var.private
}

resource "aws_route53_record" "cert" {
  for_each = var.domain == null ? {} : {
    for dvo in aws_acm_certificate.cert[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.cert[0].zone_id
}

resource "aws_acm_certificate_validation" "cert" {
  count = var.domain != null ? 1 : 0

  certificate_arn         = aws_acm_certificate.cert[0].arn
  validation_record_fqdns = [for record in aws_route53_record.cert : record.fqdn]
}