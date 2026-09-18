module "dynamo-db" {
  source = "../../../modules/dynamo-db"

  name     = "test-table"
  hash_key = "id"

  attributes = [
    {
      name = "id"
      type = "S"
    }
  ]

  encryption = {
    enabled     = false
    kms_key_arn = null
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
