terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.53"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Test bucket and object
resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "test_bucket" {
  bucket       = "eb-test-${random_id.suffix.hex}"
  force_destroy = true
}

resource "archive_file" "bundle" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/bundle.zip"
}

resource "aws_s3_object" "bundle_obj" {
  bucket  = aws_s3_bucket.test_bucket.bucket
  key     = "app.zip"
  source  = archive_file.bundle.output_path
}

module "elastic_beanstalk" {
  source = "../../../modules/elastic-beanstalk"

  application_name          = "test-app"
  solution_stack_name       = "64bit Amazon Linux 2 v3.3.6 running Node.js 16"
  environment_name          = "test-env"
  application_version_label = "v1"

  s3_bucket = aws_s3_bucket.test_bucket.bucket
  s3_key    = aws_s3_object.bundle_obj.key
}
