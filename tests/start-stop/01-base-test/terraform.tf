#############################################################################
###########                          Notes                        ###########
###########                                                       ###########
########### This is to test the absolute bear minimum of the      ###########
########### lambda function. No VPC, no bucket, no nothing        ###########
###########                                                       ###########
#############################################################################

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