module "vpc" {
    source = "../../../modules/vpc"

    name ="soci-index-test"
    public = true
    ipv4_cidr = "172.31.0.0/16"
    ingress_subnets = [{
        ipv4_cidr = "172.31.0.0/27"
        az = "us-east-1a"
        nat = false
    },
    {
        ipv4_cidr = "172.31.0.32/27"
        az = "us-east-1b"
        nat = false
    }]
    compute_subnets = []
}

module "test" {
  source = "../../../modules/index-containers"

  name = "test-for-integration"
  vpc = {
    id = module.vpc.vpc_id
    subnets = module.vpc.ingress_subnet_ids
  }
  cluster = {
    create = true
    name = "test-for-soci-indexing"
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