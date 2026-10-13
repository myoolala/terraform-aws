terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=6.25.0"
    }
  }
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

module "password_rotator" {
  source               = "../../../modules/password-rotator"
  lambda_function_name = "test-password-rotator"
}