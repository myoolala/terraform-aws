output "id" {
  value = aws_s3_bucket.main.id
}

output "arn" {
  value = aws_s3_bucket.main.arn
}

output "versioning_id" {
  value = var.versioning_enabled ? aws_s3_bucket_versioning.main.id : null
}