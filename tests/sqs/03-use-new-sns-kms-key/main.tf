module "sqs" {
  source = "../../../modules/sqs"

  name         = "test-integration-queue"
  kms = {
    key = "create"
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