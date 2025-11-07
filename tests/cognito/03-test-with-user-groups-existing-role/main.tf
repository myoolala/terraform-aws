resource "aws_iam_role" "test" {
  name = "integration-test"


  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "AssumeRole"
        Principal = {
          Federated = "cognito-identity.amazonaws.com"
        }
      }
    ]
  })
}

module "cognito" {
  source = "../../../modules/cognito"

  name = "base-test"
  groups = [{
    name = "test-1"
    description = "test-1"
    role_arn = aws_iam_role.test.arn
  }, {
    name = "test-2"
    description = "test-2"
    role_arn = aws_iam_role.test.arn
  }, {
    name = "test-3-no-role"
    description = "test-3"
  }]
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