###########################################################################
##########                        Main                           ##########
###########################################################################

resource "aws_s3_bucket" "main" {
  bucket = var.name
}

###########################################################################
##########                     Encryption                        ##########
###########################################################################

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.encryption.key
      sse_algorithm     = var.encryption.algorithm
    }
    bucket_key_enabled = var.encryption.bucket_key_enabled
  }
}

###########################################################################
##########                     Encryption                        ##########
###########################################################################

resource "aws_s3_bucket_public_access_block" "main" {
    bucket = aws_s3_bucket.main.id

    block_public_acls       = var.public_access_block.block_public_acls
    block_public_policy     = var.public_access_block.block_public_policy
    ignore_public_acls      = var.public_access_block.ignore_public_acls
    restrict_public_buckets = var.public_access_block.restrict_public_buckets
}

###########################################################################
##########                     Versioning                        ##########
###########################################################################

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Disabled"
  }
}