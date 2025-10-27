terraform {
  source = "${get_terragrunt_dir()}/../../..//modules/vpc"
}

locals {
    region = "us-east-1"
    environment = "tf-dev"
}

# Indicate the input values to use for the variables of the module.
inputs = {
  name ="public-only-vpc-test"
  public = true
  ipv4_cidr = "172.31.0.0/16"
  ipv6_conf = {
    border_group = "us-east-1"
  }
  # IPV6 config, even though it is ipv6 only, an ipv4 address is required
  # The block size, options of 0, 4, and 8, represent the size of the ipv6 blocks
  # A size of 0 gives 1 block, 4 gives 16 blocks, and 8 gives 256 blocks
  # The block itself is which of the alloted blocks you wish to use
  # So either 0, 0 to 15, or 0 to 255
  # Bear in mind, you can mix these guys up, see the public-ingress-only-ipv6-with-varying-ipv6-size for an example
  ingress_subnets = [{
    ipv4_cidr = "172.31.0.0/27"
    az = "us-east-1a"
    ipv6_only = true
    ipv6_block_size = 8
    ipv6_block = 0
  },
  {
    ipv4_cidr = "172.31.0.32/27"
    az = "us-east-1b"
    ipv6_only = true
    ipv6_block_size = 8
    ipv6_block = 1
  },
  {
    ipv4_cidr = "172.31.0.64/27"
    az = "us-east-1c"
    ipv6_only = true
    ipv6_block_size = 8
    ipv6_block = 2
  }]
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