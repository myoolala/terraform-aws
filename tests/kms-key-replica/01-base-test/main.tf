module "source_key" {
  source = "../../../modules/kms-key"

  description = "test source key"
}

module "replica_key" {
  source = "../../../modules/kms-key-replica"

  source_key_arn = module.source_key.key_arn
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
