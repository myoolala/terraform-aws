// provider block removed; provider configuration moved to required_providers.tf# S3 bucket for the bundle if uploading locally
resource "aws_s3_bucket" "bundle_bucket" {
  count        = var.create_bucket && var.source_code_path != null ? 1 : 0
  bucket       = "eb-${var.application_name}-${random_id.bucket_suffix.hex}"
  force_destroy = true
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Archive local source code if provided
resource "archive_file" "bundle" {
  count       = var.source_code_path != null ? 1 : 0
  type        = "zip"
  source_dir  = var.source_code_path
  output_path = "${path.module}/bundle.zip"
}

# Upload bundle to S3 if local source provided
resource "aws_s3_object" "bundle_obj" {
  count   = var.source_code_path != null ? 1 : 0
  bucket  = aws_s3_bucket.bundle_bucket[0].bucket
  key     = "bundle.zip"
  source  = archive_file.bundle[0].output_path
  # etag    = filemd5(archive_file.bundle[0].output_path)
}

locals {
  s3_bucket          = var.s3_bucket != null ? var.s3_bucket : (var.source_code_path != null ? aws_s3_bucket.bundle_bucket[0].bucket : "")
  s3_key             = var.s3_key != null ? var.s3_key : (var.source_code_path != null ? "bundle.zip" : "")
  default_version_label = var.application_version_label != null ? var.application_version_label : formatdate("YYYYMMDDHHmmss", timestamp())
}

# Application
resource "aws_elastic_beanstalk_application" "this" {
  name = var.application_name
  tags = var.tags
}

# Application version
resource "aws_elastic_beanstalk_application_version" "this" {
  application       = aws_elastic_beanstalk_application.this.name
  name        = local.default_version_label
  bucket            = local.s3_bucket
  key               = local.s3_key
  tags              = var.tags
}

# Environment
resource "aws_elastic_beanstalk_environment" "this" {
  application      = aws_elastic_beanstalk_application.this.name
  name          = var.environment_name != null ? var.environment_name : var.application_name
  solution_stack_name = var.solution_stack_name
  version_label = aws_elastic_beanstalk_application_version.this.name
  tags = var.tags
}
