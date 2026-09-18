module "index-containers" {
  source = "../../../modules/index-containers"

  name = "base-test"

  vpc = {
    id = "vpc-abcdef12"
    subnets = ["subnet-12345678", "subnet-87654321"]
  }

  cluster = {
    create = true
    name = "base-test-index"
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

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=6.25.0"
    }
  }
}
