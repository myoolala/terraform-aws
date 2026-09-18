module "vpc" {
  source      = "../../../modules/vpc"

  name        = "asg-test-vpc"
  public      = true
  ipv4_cidr   = "10.0.0.0/16"
  ingress_subnets = [
    {
      ipv4_cidr = "10.0.0.0/24"
      az        = "us-east-1a"
      nat       = false
    },
    {
      ipv4_cidr = "10.0.1.0/24"
      az        = "us-east-1b"
      nat       = false
    }
  ]
  compute_subnets = []
}

module "asg-service" {
  source  = "../../../modules/asg-service"
  name    = "base-test"
  ami     = "ami-0123456789abcdef0"
  instance_type = "t3.micro"

  network = {
    vpc            = module.vpc.vpc_id
    subnets        = module.vpc.ingress_subnet_ids
    additional_sgs = []
    ingresses     = []
  }

  secrets = null

  tags = {
    Environment = "test"
  }
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Environment = "test"
      Billing     = "test"
    }
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=6.25.0"
    }
  }
}

