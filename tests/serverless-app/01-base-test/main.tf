module "serverless-app" {
  source = "../../../modules/serverless-app"

  api_code_bucket_name = "base-test-api-code"
  cname                = "example.com"
  s3_prefix            = "public"
  service_name         = "base-test-app"
  ui_bucket_name       = "base-test-ui-bucket"

  # Optional arguments omitted for brevity; defaults will be used
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
      version = "\u003e=6.25.0"
    }
  }
}
