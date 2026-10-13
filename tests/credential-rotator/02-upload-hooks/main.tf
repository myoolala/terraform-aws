terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=6.25.0"
    }
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

# Zip the custom hooks module
resource "archive_file" "hooks_zip" {
  type        = "zip"
  output_path = "${path.root}/hooks.zip"
  source_file = "${path.root}/hooks.mjs"
}

resource "aws_lambda_layer_version" "hooks_layer" {
  layer_name          = "credential-rotator-hooks"
  compatible_runtimes = ["nodejs20.x", "nodejs24.x"]
  description         = "Layer containing custom hooks for credential-rotator"
  filename            = archive_file.hooks_zip.output_path
}

module "password_rotator" {
  source               = "../../../modules/credential-rotator"
  lambda_function_name = "test-credential-rotator"
  lambda_layer_arn     = aws_lambda_layer_version.hooks_layer.arn
}

resource "aws_lambda_invocation" "test" {
  function_name = module.password_rotator.lambda_function_name
  input         = jsonencode({ test = "ok" })
}
