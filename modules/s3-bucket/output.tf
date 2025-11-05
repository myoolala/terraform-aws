output "id" {
  value = aws_s3_bucket.main.id
  description = "The bucket name"
}

output "arn" {
  value = aws_s3_bucket.main.arn
  description = "The bucket ARN"
}

output "versioning_id" {
  value = var.versioning_enabled ? aws_s3_bucket_versioning.main.id : null
  description = "The version ID for the bucket"
}

output "kms_key_arn" {
  value = var.encryption.key
  description = "The default encryption key for the bucket"
}