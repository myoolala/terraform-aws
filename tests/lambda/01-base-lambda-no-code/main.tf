module "lambda" {
  source = "../../../modules/lambda"

  function_name = "test-base-lambda"
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