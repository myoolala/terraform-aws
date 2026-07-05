data "aws_caller_identity" "current" {}

locals {
  acct = data.aws_caller_identity.current.account_id
  prefix = "dev"
}

module "vpc" {
  source = "../../../modules/vpc"

  name      = "public-vpc-test"
  public    = true
  ipv4_cidr = "172.31.0.0/24"
  # ipv6_cidr = "2001:db8:1234:1a00::/56"
  ingress_subnets = [{
    ipv4_cidr = "172.31.0.0/25"
    az        = "us-east-1a"
    nat       = false
    },
    {
      ipv4_cidr = "172.31.0.128/25"
      az        = "us-east-1b"
      nat       = false
  }]
  compute_subnets = []
}

module "application_logs_bucket" {
  source = "../../../modules/s3-bucket"

  name = "oh-wow-this-super-exclusive-existing-bucket"
}

resource "aws_s3_bucket_policy" "app_log_policy" {
  bucket = module.application_logs_bucket.id
  policy = jsonencode({
    "Version":"2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "logdelivery.elasticloadbalancing.amazonaws.com"
        },
        "Action": "s3:PutObject",
        "Resource": "${module.application_logs_bucket.arn}/${local.prefix}/AWSLogs/${local.acct}/*"
      }
    ]
  })
}

module "load_balancer" {
  source = "../../../modules/load-balancer"

  name    = "load-balancer-ipv4"
  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.ingress_subnet_ids

  access_logs = {
    bucket = module.application_logs_bucket.id
    prefix = local.prefix
  }
}


provider "aws" {
  region = "us-east-1"
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">6.19.0"
    }
  }
}