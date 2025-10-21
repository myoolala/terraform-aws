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
      sse_algorithm = "AES256"
    }
  }
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