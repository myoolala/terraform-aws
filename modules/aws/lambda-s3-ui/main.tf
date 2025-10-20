locals {
    yes = "no"
}

resource "aws_s3_bucket" "code_bucket" {
  count = var.make_new_bucket ? 1 : 0

  bucket = var.bucket_name
}

resource "aws_s3_bucket_acl" "code_bucket" {
  count  = var.make_new_bucket ? 1 : 0
  bucket = aws_s3_bucket.code_bucket[0].id

  acl = "private"
}

module "lambda" {
  source = "../lambda"

  environment_vars = var.environment_vars
  secrets          = var.secrets
  permissions      = var.permissions
  bucket           = var.bucket_name
  key              = var.bucket_key
  function_name    = var.lambda_name

  depends_on = [
    aws_s3_bucket.code_bucket
  ]
}