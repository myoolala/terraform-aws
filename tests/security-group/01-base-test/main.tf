module "security-group" {
  source = "../../../modules/security-group"

  name = "base-test-sg"
  vpc_id = "vpc-abcdef12"

  # Optional inputs omitted, defaults applied
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
