locals {
  iam_user_name  = "smtp-test-user"
  ssm_parameter   = "/smtp/credentials"
  secrets_name    = "smtp-credentials"
  sns_topic_name  = "smtp-errors"
}

data "aws_region" "current" {}

resource "aws_iam_user" "smtp_user" {
  name = local.iam_user_name
}


resource "aws_ssm_parameter" "smtp_ssm" {
  name  = local.ssm_parameter
  type  = "SecureString"
  value = "placeholder"
}

resource "aws_secretsmanager_secret" "smtp_secret" {
  name = local.secrets_name
}



resource "aws_sns_topic" "smtp_errors" {
  name = local.sns_topic_name
}

# Lambda module
module "rotate_smtp" {
  source      = "../../../modules/rotate-smtp-credentials"

  name        = "smtp-credentials-rotator"
  iam_user    = aws_iam_user.smtp_user.name
  ssm_parameter = [aws_ssm_parameter.smtp_ssm.name]
  secretsmanager_secret = [aws_secretsmanager_secret.smtp_secret.arn]
  sns_topic  = [aws_sns_topic.smtp_errors.arn]
  permissions = null
}

# Trigger the Lambda via CloudWatch Events
resource "aws_cloudwatch_event_rule" "cron_trigger" {
  name                = "smtp-rotator-cron"
  schedule_expression = "rate(1 minute)"
}

resource "aws_lambda_permission" "cron_invoker" {
  statement_id  = "AllowInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.rotate_smtp.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cron_trigger.arn
}

resource "aws_cloudwatch_event_target" "scheduler" {
  rule      = aws_cloudwatch_event_rule.cron_trigger.name
  target_id = module.rotate_smtp.function_name
  arn       = module.rotate_smtp.function_arn
  input = jsonencode({
    mode             = "test"
    iam_user         = aws_iam_user.smtp_user.name
  })
}

# Providers
provider "aws" {
  region = "us-east-1"
}

# provider "random" {}

