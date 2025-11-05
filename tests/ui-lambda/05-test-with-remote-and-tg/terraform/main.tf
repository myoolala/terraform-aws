#############################################################################
###########                          Notes                        ###########
###########                                                       ###########
########### I am going insane                                     ###########
###########                                                       ###########
#############################################################################

resource "random_string" "suffix" {
  length  = 8
  special = false # Set to true to include special characters
  numeric = false # Set to true to include numbers
  upper   = false # Set to true to include uppercase letters
  lower   = true  # Set to true to include lowercase letters
}

module "s3_target" {
  source = "github.com/myoolala/terraform-aws/modules/s3-bucket?ref=next-work"

  name = "test-integration-${random_string.suffix.result}"
}

resource "aws_lb_target_group" "forwarder" {
  name        = "lambda-ui-integration-test"
  protocol    = "HTTPS"
  vpc_id      = null
  target_type = "lambda"
}

module "lambda-ui" {
  source = "github.com/myoolala/terraform-aws/modules/lambda-s3-ui?ref=next-work"

  lambda_name = "test-base-lambda"
  alb_tg_arn  = aws_lb_target_group.forwarder.arn
  config = {
    bucket = module.s3_target.id
    prefix = "/latest"
  }
  vpc_config = null
}