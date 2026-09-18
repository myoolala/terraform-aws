module "secrets" {
  source = "../../../modules/secrets"

  secrets = [
    {
      name  = "my-secret"
      value = "super-secret-value"
    }
  ]
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
