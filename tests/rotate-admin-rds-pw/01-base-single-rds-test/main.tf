locals {
  db_arn        = "arn:aws:rds:us-east-1:123456789012:db:my-db-instance"
  db_identifier = "my-db-instance"
  secret_arn    = "arn:aws:secretsmanager:us-east-1:123456789012:secret:db-admin-connection-info-abcdef"
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
    resources = [local.db_arn]
  }
  statement {
    sid    = "secretAccess"
    effect = "Allow"
    actions = [
      "secretsmanager:PutSecretValue"
    ]
    resources = [local.secret_arn]
  }
}

module "test" {
  source = "../../../modules/rotate-admin-rds-pw"

  name        = "test-integration-rotate-rds-pw"
  permissions = data.aws_iam_policy_document.rds_pw_updates.json
  event_schedule_input = {
    rdsIdentifier        = local.db_identifier
    rdsAdminInfoLocation = local.secret_arn
  }

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