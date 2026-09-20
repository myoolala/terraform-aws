module "lambda-s3-ui" {
  source = "../../../modules/lambda-s3-ui"

  alb_tg_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/example/abcd"
  lambda_name = "test-ui-lambda"
  config = {
    bucket = "test-bucket"
    prefix = "assets"
  }

  vpc_config = null
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
