module "cognito" {
  source = "../../../modules/cognito"

  name = "base-test"
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
      version = "=6.19.0"
    }
  }
}