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

# Add AWS provider
provider "aws" {
  region = "us-east-1"
}
