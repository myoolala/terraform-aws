locals {
  db_arns = [
    "arn:aws:rds:us-east-1:123456789012:db:my-db-instance",
    "arn:aws:rds:us-east-1:123456789012:db:my-other-db-instance"
  ]
  db_identifiers = [
    "my-db-instance",
    "my-other-db-instance"
  ]
  secret_arns = [
    "arn:aws:secretsmanager:us-east-1:123456789012:secret:db-admin-connection-info-abcdef",
    "arn:aws:secretsmanager:us-east-1:123456789012:secret:other-db-admin-connection-info-abcdef"
  ]
}

data "aws_iam_policy_document" "rds_pw_updates" {
  statement {
    sid    = "dbAccess"
    effect = "Allow"
    actions = [
      "rds:DescribeDbInstance",
      "rds:DescribeDbCluster",
      "rds:ModifyDbInstance",
      "rds:ModifyDbCluster",
    ]
    resources = local.db_arns
  }
  statement {
    sid    = "secretAccess"
    effect = "Allow"
    actions = [
      "secretsmanager:PutSecretValue"
    ]
    resources = local.secret_arns
  }
}

module "test" {
  source = "../../../modules/rotate-admin-rds-pw"

  name                 = "test-integration-rotate-rds-pw"
  permissions          = data.aws_iam_policy_document.rds_pw_updates.json
  event_schedule_input = null
  schedule             = null
}


##################################################################
##################################################################
##########                Cron trigger                  ##########
##################################################################
##################################################################

resource "aws_cloudwatch_event_rule" "cron_trigger" {
  count = 2

  name                = "test-${count.index + 1}-cron-trigger"
  schedule_expression = "rate(1 day)"
}

resource "aws_lambda_permission" "cron_perms" {
  count = 2

  statement_id  = "cron-invoke-${count.index + 1}"
  action        = "lambda:InvokeFunction"
  function_name = module.test.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cron_trigger[count.index].arn
}

resource "aws_cloudwatch_event_target" "schedule" {
  count = 2

  target_id = "test-${count.index + 1}-cron-trigger"
  arn       = module.test.function_arn
  rule      = aws_cloudwatch_event_rule.cron_trigger[count.index].name
  input = jsonencode({
    rdsIdentifier        = local.db_identifiers[count.index]
    rdsAdminInfoLocation = local.secret_arns[count.index]
    mode                 = "instance"
    pwLength             = 64
  })
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