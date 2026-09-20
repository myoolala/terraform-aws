module "scheduled-task" {
  source = "../../../modules/scheduled-task"

  cluster         = { create = true, name = "base-test-cluster" }
  service_name    = "base-test-service"
  service_subnets = ["subnet-12345678", "subnet-87654321"]
  trigger         = { schedule_expression = "rate(1 hour)" }
  vpc_id          = "vpc-abcdef12"

  # optional values left to defaults
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
