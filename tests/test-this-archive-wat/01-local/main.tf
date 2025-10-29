#############################################################################
###########                          Notes                        ###########
###########                                                       ###########
########### I am insane                                           ###########
###########                                                       ###########
#############################################################################

module "test" {
  source = "../../modules/test-archive-module"
}

output "a" {
  value = module.test.a
}

output "b" {
  value = module.test.b
}

output "c" {
  value = module.test.c
}

output "d" {
  value = module.test.d
}

output "e" {
  value = module.test.e
}

output "f" {
  value = module.test.f
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