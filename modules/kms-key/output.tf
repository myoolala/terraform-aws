output "alias_arn" {
    value = var.alias ? aws_kms_alias.this[0].arn : null
    description = "ARN of the KMS Key Alias if one was created"
}

output "key_arn" {
    value = aws_kms_key.this.arn
    description = "ARN of the KMS Key"
}

output "key_id" {
    value = aws_kms_key.this.key_id
    description = "ID of the KMS KEy"
}