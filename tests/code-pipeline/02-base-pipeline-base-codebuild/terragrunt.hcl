terraform {
  source = "${get_terragrunt_dir()}/../../..//tests/code-pipeline/02-base-pipeline-base-codebuild/terraform"
}

locals {
    region = "us-east-1"
    environment = "tf-integration-test"
}

# Indicate the input values to use for the variables of the module.
inputs = {
}


# Indicate what region to deploy the resources into
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents = <<EOF
provider "aws" {
  region              = "${local.region}"
  default_tags {
    tags = {
      Environment = "${local.environment}"
      Billing = "${local.environment}"
    }
  }
}
EOF
}