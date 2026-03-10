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
module "fargate_service" {
  source = "../../../modules/fargate-service"

  service_name = "test-service"
  network = {
    vpc_id  = module.vpc.vpc_id
    subnets = module.vpc.compute_subnet_ids
  }
  cluster = {
    name   = "test-service"
    create = true
  }
  ecr = {
    create       = true
    scan_on_push = false
  }
  image_tag     = "latest"
  log_retention = 7
#   secrets       = null
  env_vars = {

  }
  lb = {
    subnets = module.vpc.ingress_subnet_ids
    type = "network"
    internal = true
    port_mappings = [{
      listen_port  = 443
      forward_port = 3000
      lb_protocol = "TCP"
      tg_protocol = "TCP"
      # health_check = {

      # }
    }]
  }

  desired_count = 0
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