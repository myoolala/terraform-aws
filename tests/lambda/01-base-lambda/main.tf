resource "archive_file" "source" {
  type        = "zip"
  source_file = "${path.module}/index.js"
  output_path = "${path.module}/output/lambda.zip"
}

module "lambda" {
  source = "../../../modules/lambda"

  function_name = "test-base-lambda"
  file_path     = archive_file.source.output_path
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