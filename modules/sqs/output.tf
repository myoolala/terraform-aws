output "sqs_arn" {
  value       = aws_sqs_queue.this.arn
  description = "ARN for the SQS Queue"
}

output "kms_key" {
  value       = var.kms.key == "create" ? module.kms_key[0].key_id : var.kms.key
  description = "KMS key id that was provided or created"
}

output "kms_key_arn" {
  value       = var.kms.key == "create" ? module.kms_key[0].key_arn : null
  description = "KMS key ARN that was created"
}

output "kms_key_alias_arn" {
  value       = var.kms.key == "create" ? module.kms_key[0].alias_arn : null
  description = "KMS key Alias ARN that was created"
}