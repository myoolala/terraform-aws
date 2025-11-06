resource "random_string" "suffix" {
  length  = 8
  special = false # Set to true to include special characters
  numeric = false # Set to true to include numbers
  upper   = false # Set to true to include uppercase letters
  lower   = true  # Set to true to include lowercase letters
}

module "test" {
    source = "../../../modules/s3-bucket"

    name = "test-integration-${random_string.suffix.result}"
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