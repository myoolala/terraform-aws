module "lambda-with-api" {
  source = "../../../modules/lambda-with-api"

  bucket_key   = "s3://test-bucket/lambda.zip"
  bucket_name  = "test-bucket"
  endpoints    = ["/test"]
  lambda_name  = "test-lambda"
  path_prefix  = "/"
  // Optional arguments left to defaults
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Environment = "tf-integration-test"
      Billing     = "tf-integration-test"
    }
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=6.25.0"
    }
  }
}
