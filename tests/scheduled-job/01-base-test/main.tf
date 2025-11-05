module "vpc" {
  source = "../../../modules/vpc"

  name      = "public-vpc-test"
  public    = false
  ipv4_cidr = "172.31.0.0/24"
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

module "test" {
  source = "../../../modules/scheduled-task"

  service_name = "the-test-of-tests"
  cluster = {
    create = true
    name = "the-test-of-tests"
  }
  vpc_id = module.vpc.vpc_id
  service_subnets = module.vpc.ingress_subnet_ids
  schedule_expression = "cron(0 6 * * ? *)"
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