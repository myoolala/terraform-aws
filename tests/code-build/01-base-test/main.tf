module "code-build" {
  source = "../../../modules/code-build"

  name = "base-test"
  description = "Test CodeBuild project"
  source_config = {
    type      = "GITHUB"
    buildspec = "buildspec.yml"
  }
  vpc_config = {
    vpc_id = "vpc-123456"
    subnet_ids = ["subnet-123"]
    subnet_arns = ["arn:aws:ec2:us-east-1:123456789012:subnet/subnet-123"]
    sg_ids = []
    create_sg = false
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
