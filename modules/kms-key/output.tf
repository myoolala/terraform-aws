output "alias_arn" {
    value = var.alias ? aws_kms_alias.this[0].arn : null
}

output "key_arn" {
    value = aws_kms_key.this.arn
}

output "key_id" {
    value = aws_kms_key.this.key_id
}