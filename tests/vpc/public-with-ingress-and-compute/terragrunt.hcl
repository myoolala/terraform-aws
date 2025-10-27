terraform {
  source = "${get_terragrunt_dir()}/../../..//modules/vpc"
}

locals {
    region = "us-east-1"
    environment = "tf-dev"
}

# Indicate the input values to use for the variables of the module.
inputs = {
  name ="public-vpc-test"
  public = true
  ipv4_cidr = "172.31.0.0/16"
  # ipv6_cidr = "2001:db8:1234:1a00::/56"
  ingress_subnets = [{
    ipv4_cidr = "172.31.0.0/27"
    az = "us-east-1a"
    nat = true
  },
  {
    ipv4_cidr = "172.31.0.32/27"
    az = "us-east-1b"
    nat = true
  },
  {
    ipv4_cidr = "172.31.0.64/27"
    az = "us-east-1c"
    nat = true
  }]
  compute_subnets = [{
    ipv4_cidr = "172.31.1.0/25"
    az = "us-east-1a"
  },
  {
    ipv4_cidr = "172.31.1.128/25"
    az = "us-east-1b"
  },
  {
    ipv4_cidr = "172.31.2.0/25"
    az = "us-east-1c"
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