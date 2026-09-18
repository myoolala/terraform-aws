module "vpc" {
  source      = "../../../modules/vpc"
  name        = "aurora-test-vpc"
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

resource "aws_db_subnet_group" "aurora" {
  name       = "aurora-subnet-group"
  subnet_ids = module.vpc.ingress_subnet_ids
}

module "aurora" {
  source = "../../../modules/aurora"

  cluster_identifier = "aurora-test-cluster"
  engine = "aurora-mysql"
  engine_version = "8.032"
  database_name = "testdb"
  master_username = "root"
  master_password = "Secret123!"
  db_subnet_group_name = aws_db_subnet_group.aurora.id
  vpc_security_group_ids = [module.vpc.default_sg]
  port = 3306
  storage_encrypted = true
  kms_key_id = "arn:aws:kms:us-east-1:123456789012:alias/aws/rds"
  backup_retention_period = 7
  preferred_backup_window = "07:00-09:00"
  iam_database_authentication_enabled = false
  apply_immediately = true
  tags = {
    Environment = "tf-dev"
    Billing = "tf-dev"
  }
  instances = {}
  final_snapshot_seed = "seed"
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

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=6.25.0"
    }
  }
}
