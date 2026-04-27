provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Environment = "tf-integration-test"
      Billing     = "tf-integration-test"
    }
  }
}

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

module "rds_instance_db" {
    source = "../../../modules/rds-instance-db"

    name = "rds-instance-test"
    port = 5432
    vpc_config = {
      vpc_id = module.vpc.vpc_id
      subnets = module.vpc.compute_subnet_ids
    }
    configs = {
      "default" = {
        pg_name = "test"
        engine = "postgres"
        engine_version = "18.3"
        pg_family = "postgres18"
      }
    }
    skip_final_snapshot = true
}

output "output" {
  value = module.rds_instance_db
}