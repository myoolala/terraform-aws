module "cognito" {
  source = "../../../modules/cognito"

  name = "base-test"
  groups = [{
    name = "test-1"
    description = "test-1"
  }, {
    name = "test-2"
    description = "test-2"
  }, {
    name = "test-3-no-role"
    description = "test-3"
  }]
  client_config = {
    name = "test-for-test"
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
      source = "hashicorp/aws"
      version = "=6.19.0"
   }
  }
}