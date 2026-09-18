module "code-build" {
  source = "../../../modules/code-build"

  name = "base-test"
  description = "Test CodeBuild project"
  source_config = {
    type      = "GITHUB"
    buildspec = "buildspec.yml"
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
