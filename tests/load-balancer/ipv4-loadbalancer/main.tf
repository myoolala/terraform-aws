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

module "load_balancer" {
  source = "../../../modules/load-balancer"

  name    = "load-balancer-ipv4"
  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.ingress_subnet_ids
}


provider "aws" {
  region = "us-east-1"
}