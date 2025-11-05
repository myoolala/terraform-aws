#############################################################################
###########                          Notes                        ###########
###########                                                       ###########
########### This is to test the deploying the lambda into a vpc   ###########
########### with the TG in the vpc and no further configuraiton   ###########
########### than that                                             ###########
#############################################################################

module "vpc" {
  source = "../../../modules/vpc"

  name      = "private-vpc-test"
  ipv4_cidr = "172.31.0.0/16"
  ingress_subnets = [{
    ipv4_cidr = "172.31.0.0/27"
    az        = "us-east-1a"
    },
    {
      ipv4_cidr = "172.31.0.32/27"
      az        = "us-east-1b"
  }]
  compute_subnets = [{
    ipv4_cidr = "172.31.1.0/25"
    az        = "us-east-1a"
    },
    {
      ipv4_cidr = "172.31.1.128/25"
      az        = "us-east-1b"
  }]
}

resource "random_string" "suffix" {
  length  = 8
  special = false # Set to true to include special characters
  numeric = false # Set to true to include numbers
  upper   = false # Set to true to include uppercase letters
  lower   = true  # Set to true to include lowercase letters
}

module "s3_target" {
  source = "../../../modules/s3-bucket"

  name = "test-integration-${random_string.suffix.result}"
}

resource "aws_lb_target_group" "forwarder" {
  name        = "lambda-ui-integration-test"
  protocol    = "HTTPS"
  vpc_id      = module.vpc.vpc_id
  target_type = "lambda"
}

module "lambda-ui" {
  source = "../../../modules/lambda-s3-ui"

  lambda_name = "test-base-lambda"
  alb_tg_arn  = aws_lb_target_group.forwarder.arn
  config = {
    bucket = module.s3_target.id
    prefix = "/latest"
  }
  vpc_config = {
    subnets = module.vpc.compute_subnet_ids
  }
  sg_config = {
    create = true
    vpc_id = module.vpc.vpc_id
  }
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