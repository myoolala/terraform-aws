data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

locals {
  region   = data.aws_region.current.region
  zip_name = "1234"
}

##################################################################
##########                   Code Bucket                ##########
##################################################################
resource "random_string" "suffix" {
  length  = 8
  special = false # Set to true to include special characters
  numeric = true  # Set to true to include numbers
  upper   = false # Set to true to include uppercase letters
  lower   = true  # Set to true to include lowercase letters
}

module "code_bucket" {
  count  = var.code_bucket_config == null ? 1 : 0
  source = "../s3-bucket"

  name = "${var.name}-${random_string.suffix.result}"
}

locals {
  source_bucket = {
    id     = var.code_bucket_config != null ? var.code_bucket_config.id : module.code_bucket[0].id
    arn    = var.code_bucket_config != null ? var.code_bucket_config.arn : module.code_bucket[0].arn
    prefix = var.code_bucket_config != null ? var.code_bucket_config.prefix : "/"
  }
}

##################################################################
##########                  Image builder               ##########
##################################################################

# data "http" "sico_download" {
#   url = "https://checkpoint-api.hashicorp.com/v1/check/terraform"
# }

# resource "aws_s3_object" "file_upload" {
#   bucket = local.source_bucket.id
#   key    = "${local.source_bucket.prefix}${local.zip_name}"
#   source = "${path.module}/my_files.zip"
#   etag   = "${filemd5("${path.module}/my_files.zip")}"
# }

module "image_build" {
  source = "../code-build"

  name        = var.name
  description = "SOCI index process for ECR images"
  source_config = {
    type      = "NO_SOURCE"
    buildspec = file("${path.module}/buildspec.yml")
  }
}

##################################################################
##########                     Indexer                  ##########
##################################################################

module "index" {
  source = "../scheduled-task"

  service_name    = var.name
  vpc_id          = var.vpc.id
  cluster         = var.cluster
  service_subnets = var.vpc.subnets
  trigger = {
    event_pattern = var.event_filter_override != null ? var.event_filter_override : jsonencode({
      source      = ["aws.ecr"]
      detail-type = ["ECR Image Action"]
      detail = {
        action-type = ["PUSH"]
        result      = ["SUCCESS"]
      }
      region = [
        local.region
      ]
    })
  }
}