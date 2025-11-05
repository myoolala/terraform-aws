data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

locals {
  acct_id   = data.aws_caller_identity.current.account_id
  region    = data.aws_region.current.region
  partition = data.aws_partition.current.partition
  permissions = var.permissions != null ? [
    var.permissions
  ] : null
}

data "aws_iam_policy_document" "this" {
  statement {
    sid = "Default"

    effect = "Allow"
    actions = [
      "kms:*",
    ]
    principals {
      type = "AWS"
      identifiers = [
        "arn:${local.partition}:iam::${local.acct_id}:root"
      ]
    }
    resources = ["*"]
  }


  source_policy_documents   = local.permissions
  override_policy_documents = local.permissions
}

resource "aws_kms_key" "this" {
  is_enabled              = var.is_enabled
  enable_key_rotation     = var.rotation_period != null
  rotation_period_in_days = var.rotation_period
  description             = var.description
  deletion_window_in_days = var.deletion_window_in_days
  key_usage               = var.key_usage
  policy                  = data.aws_iam_policy_document.this.json

  tags = var.tags
}

resource "aws_kms_alias" "this" {
  count = var.alias != null ? 1 : 0

  name          = var.alias
  target_key_id = aws_kms_key.this.key_id
}