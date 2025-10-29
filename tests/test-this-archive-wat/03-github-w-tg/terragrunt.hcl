terraform {
  source = "${get_terragrunt_dir()}/../../..//tests/test-this-archive-wat/03-github-w-tg/terraform"
}

locals {
    region = "us-east-1"
    environment = "tf-dev"
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