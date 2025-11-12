#############################################################################
###########                          Notes                        ###########
###########                                                       ###########
###########   This is to test the integration with AutoScaling    ###########
###########    Groups. No need to check what the rules invokes    ###########
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

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

module "asg" {
  source = "../../../modules/asg-service"

  name = "test-for-start-stop"
  ami = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  network = {
    vpc = module.vpc.vpc_id
    subnets = module.vpc.compute_subnet_ids
  }
  asg_tags = {
    ServiceRunSchedule = "2-6/06:30/06:59"
  }
  capacity = {
    min = 0
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