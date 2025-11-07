module "sns" {
  source = "../../../modules/sns"

  name         = "test-integration-topic"
  display_name = "Test integration topic"
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