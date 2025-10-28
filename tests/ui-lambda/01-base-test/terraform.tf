#############################################################################
###########                          Notes                        ###########
###########                                                       ###########
########### This is to test the absolute bear minimum of the      ###########
########### lambda ui. No VPC, no bucket, no nothing              ###########
###########                                                       ###########
#############################################################################

resource "aws_lb_target_group" "forwarder" {
  name        = "lambda-ui-integration-test"
  port        = null
  protocol    = "HTTPS"
  vpc_id      = null
  target_type = "lambda"
}

module "lambda-ui" {
  source = "../../../modules/lambda-s3-ui"

  lambda_name = "test-base-lambda"
  alb_tg_arn  = aws_lb_target_group.forwarder.arn
  config = {
    bucket = "fu"
    prefix = "bar"
  }
  vpc_config = null
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