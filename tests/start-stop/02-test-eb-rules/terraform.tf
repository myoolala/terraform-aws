#############################################################################
###########                          Notes                        ###########
###########                                                       ###########
########### This is to test the integration with EventBridge      ###########
########### rules. No need to check what the rules invokes        ###########
###########                                                       ###########
#############################################################################

  # schedule = "2-6/06:30/18:59" # Mon through Friday at 0630 to 1900
resource "aws_cloudwatch_event_rule" "schedule_trigger" {
  name                = "test-rule"
  # So we can support tags, but the api to get the tags is.... gross
  # Maybe make it a feature flag? Or create a ddb cache of what to check... which
  # honestly is not a bad idea. Or use s3 as a cache. Investigate that @TODO
  description         = "test --- 2-6/06:30/06:59"
  schedule_expression = "rate(1 day)"
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