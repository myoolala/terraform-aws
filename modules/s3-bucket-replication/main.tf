provider "aws" {
  alias = "primary"
}

provider "aws" {
  alias = "backup"
}

# Create the backup bucket in the backup provider
resource "aws_s3_bucket" "backup" {
  provider = aws.backup
  bucket   = var.backup_bucket_name != "" ? var.backup_bucket_name : "${var.source_bucket_name}-backup"
}

# Optional public access block for backup bucket
resource "aws_s3_bucket_public_access_block" "backup" {
  provider = aws.backup
  bucket   = aws_s3_bucket.backup.id

  block_public_acls       = lookup(var.public_access_block, "block_public_acls", true)
  block_public_policy     = lookup(var.public_access_block, "block_public_policy", true)
  ignore_public_acls      = lookup(var.public_access_block, "ignore_public_acls", true)
  restrict_public_buckets = lookup(var.public_access_block, "restrict_public_buckets", true)
}

# Optional versioning on backup bucket
resource "aws_s3_bucket_versioning" "backup" {
  provider = aws.backup
  bucket   = aws_s3_bucket.backup.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Disabled"
  }
}

# IAM role for replication from primary to backup
resource "aws_iam_role" "replication_role_primary" {
  provider = aws.primary
  name     = "${var.source_bucket_name}-replication-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "s3.amazonaws.com"
      }
    }]
  })
}

# IAM role for replication from backup to primary
resource "aws_iam_role" "replication_role_backup" {
  provider = aws.backup
  name     = "${var.source_bucket_name}-replication-role-backup"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "s3.amazonaws.com"
      }
    }]
  })
}

# Data source to get source bucket ARN
data "aws_s3_bucket" "source" {
  provider = aws.primary
  bucket   = var.source_bucket_name
}

# Replication configuration from primary to backup
resource "aws_s3_bucket_replication_configuration" "primary_to_backup" {
  provider = aws.primary
  bucket   = var.source_bucket_name
  role     = aws_iam_role.replication_role_primary.arn

  rule {
    id     = "primary-to-backup"
    status = "Enabled"

    destination {
      bucket = aws_s3_bucket.backup.arn
    }
  }
}

# Optionally add reverse replication if two-way
resource "aws_s3_bucket_replication_configuration" "backup_to_primary" {
  provider = aws.backup
  bucket   = aws_s3_bucket.backup.id
  role     = aws_iam_role.replication_role_backup.arn

  count = var.replication_mode == "two-way" ? 1 : 0

  rule {
    id     = "backup-to-primary"
    status = "Enabled"

    destination {
      bucket = data.aws_s3_bucket.source.arn
    }
  }
}
