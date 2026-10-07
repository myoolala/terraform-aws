# Provider
provider "aws" {
  region = "us-east-1"
}

# VPC module for ALB
module "vpc" {
  source    = "../../../modules/vpc"
  name      = "test-vpc"
  public    = true
  ipv4_cidr = "172.31.0.0/24"
  ingress_subnets = [
    {
      ipv4_cidr = "172.31.0.0/26"
      az        = "us-east-1a"
      nat       = false
    },
    {
      ipv4_cidr = "172.31.0.64/26"
      az        = "us-east-1b"
      nat       = false
    }
  ]
  compute_subnets = []
}

# WAF module
module "waf" {
  source         = "../../../modules/wafv2"
  name           = "example-waf"
  default_action = "ALLOW"

  managed_rule_groups = [
    {
      name   = "AWSManagedRulesCommonRuleSet"
      vendor = "AWS"
    }
  ]
  ip_sets = [
    {
      name      = "blocked-ips"
      addresses = ["192.0.2.0/24"]
      action    = "BLOCK"
    }
  ]
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.25.0"
    }
  }
}
