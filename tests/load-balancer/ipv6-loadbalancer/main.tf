module "vpc" {
    source = "../../../modules/vpc"

    
  name ="public-only-vpc-test"
  public = true
  ipv4_cidr = "172.31.0.0/16"
  ipv6_conf = {
    border_group = "us-east-1"
  }
  # IPV6 config, even though it is ipv6 only, an ipv4 address is required
  # The block size, options of 0, 4, and 8, represent the size of the ipv6 blocks
  # A size of 0 gives 1 block, 4 gives 16 blocks, and 8 gives 256 blocks
  # The block itself is which of the alloted blocks you wish to use
  # So either 0, 0 to 15, or 0 to 255
  # Bear in mind, you can mix these guys up, see the public-ingress-only-ipv6-with-varying-ipv6-size for an example
  ingress_subnets = [{
    ipv4_cidr = "172.31.0.0/27"
    az = "us-east-1a"
    ipv6_only = true
    ipv6_block_size = 8
    ipv6_block = 0
  },
  {
    ipv4_cidr = "172.31.0.32/27"
    az = "us-east-1b"
    ipv6_only = true
    ipv6_block_size = 8
    ipv6_block = 1
  }]
}

module "load_balancer" {
    source = "../../../modules/load-balancer"

    name = "load-balancer-ipv4"
    vpc_id = module.vpc.vpc_id
    subnets = module.vpc.ingress_subnet_ids
}


provider "aws" {
  region              = "us-east-1"
}