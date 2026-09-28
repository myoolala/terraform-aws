output "web_acl_id" {
  description = "The ID of the created Web ACL."
  value       = aws_wafv2_web_acl.this.id
}

output "web_acl_arn" {
  description = "The ARN of the created Web ACL."
  value       = aws_wafv2_web_acl.this.arn
}

output "association_arn" {
  description = "The ARN of the Web ACL association with the ALB, if created."
  value       = try(aws_wafv2_web_acl_association.this[0].arn, null)
}
