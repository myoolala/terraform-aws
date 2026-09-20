module "task-definition" {
  source = "../../../modules/task-definition"

  name          = "base-test"
  service_name  = "base-test-service"
  image         = "nginx:latest"
  log_group     = "base-test-log"
  // Optional values left to defaults
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
