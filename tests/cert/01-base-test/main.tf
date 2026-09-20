resource "aws_route53_zone" "test" {
  name = "example.com."
}

module "cert" {
  source = "../../../modules/cert"

  # Optional domain. Leave null for no certificate.
  domain      = "example.com"
  hosted_zone = "Z1234567890"
  private     = true
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
