locals {
    region = "us-east-1"
    environment = "tf-dev"
}

# Indicate the input values to use for the variables of the module.
module "test_vpc" {
  source = "../../../modules/vpc"

  name ="private-vpc-test"
  ipv4_cidr = "172.31.0.0/16"
  ingress_subnets = [{
    ipv4_cidr = "172.31.0.0/27"
    az = "us-east-1a"
  },
  {
    ipv4_cidr = "172.31.0.32/27"
    az = "us-east-1b"
  },
  {
    ipv4_cidr = "172.31.0.64/27"
    az = "us-east-1c"
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
  other_subnets = {
    databases = [{
      ipv4_cidr = "172.31.3.0/25"
      az = "us-east-1a"
    },
    {
      ipv4_cidr = "172.31.2.128/25"
      az = "us-east-1b"
    },
    {
      ipv4_cidr = "172.31.3.128/25"
      az = "us-east-1c"
    }]
  }
}

provider "aws" {
  region              = "${local.region}"
  default_tags {
    tags = {
      Environment = "${local.environment}"
      Billing = "${local.environment}"
    }
  }
}

terraform {
  required_providers {
    archive = {
      source = "hashicorp/archive"
      version = "2.7.1"
   }
   aws = {
      source = "hashicorp/aws"
      version = "=6.19.0"
   }
  }
}