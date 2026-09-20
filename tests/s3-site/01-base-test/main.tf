module "s3-site" {
  source = "../../../modules/s3-site"

  cname          = "example.com"
  host_s3_bucket = "test-site-bucket"
  s3_prefix      = "root"
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
