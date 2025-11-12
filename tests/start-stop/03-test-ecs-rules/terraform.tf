#############################################################################
###########                          Notes                        ###########
###########                                                       ###########
###########  This is to test the integration with ECS services.   ###########
###########       No need to check what the rules invokes         ###########
###########                                                       ###########
#############################################################################

# Indicate the input values to use for the variables of the module.
module "vpc" {
  source = "../../../modules/vpc"

  name ="private-vpc-test"
  ipv4_cidr = "172.31.0.0/16"
  ingress_subnets = []
  compute_subnets = [{
    ipv4_cidr = "172.31.1.0/25"
    az = "us-east-1a"
  },
  {
    ipv4_cidr = "172.31.1.128/25"
    az = "us-east-1b"
  }]
}


module "test_service" {
  source = "../../../modules/fargate-service"

  service_name = "test-for-start-stop"
  network = {
    vpc_id = module.vpc.vpc_id
    subnets = module.vpc.compute_subnet_ids
  }
  cluster = {
    create = true
    name = "test-for-start-stop"
  }
  tags = {
    ServiceRunSchedule = "2-6/06:30/06:59"
  }
}

module "start_stop_lambder" {
  source = "../../../modules/start-stop"

  name = "start-stop-test"
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