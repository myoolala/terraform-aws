output "key_id" {
  value       = aws_kms_replica_key.this.key_id
  description = "ID of the replica KMS key"
}

output "key_arn" {
  value       = aws_kms_replica_key.this.arn
  description = "ARN of the replica KMS key"
}

output "alias_arn" {
  value       = var.replica_alias == null ? null : aws_kms_alias.this[0].arn
  description = "ARN of the alias for the replica key if created"
}
