output "backup_bucket_id" {
  value       = aws_s3_bucket.backup.id
  description = "The name of the backup bucket"
}

output "backup_bucket_arn" {
  value       = aws_s3_bucket.backup.arn
  description = "The ARN of the backup bucket"
}

output "replication_role_arn" {
  value       = aws_iam_role.replication_role_primary.arn
  description = "ARN of the replication role on the primary account"
}
