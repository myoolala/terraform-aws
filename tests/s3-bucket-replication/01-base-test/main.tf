resource "random_string" "suffix" {
  length  = 8
  special = false
  numeric = false
  upper   = false
  lower   = true
}

module "source" {
  source = "../../../modules/s3-bucket"
  name   = "test-integration-${random_string.suffix.result}"
}

module "replication" {
  source             = "../../../modules/s3-bucket-replication"
  source_bucket_name = module.source.id
  replication_mode   = "one-way"
}

provider "aws" {
  alias  = "primary"
  region = "us-east-1"

  default_tags {
    tags = {
      Environment = "tf-integration-test"
      Billing     = "tf-integration-test"
    }
  }
}

provider "aws" {
  alias  = "backup"
  region = "us-east-1"
}
