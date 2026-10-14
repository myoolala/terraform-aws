data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

locals {
  acct_id     = data.aws_caller_identity.current.account_id
  partition   = data.aws_partition.current.partition
  permissions = var.permissions != null ? [var.permissions] : null
}

data "aws_iam_policy_document" "this" {
  statement {
    sid     = "Default"
    effect  = "Allow"
    actions = ["kms:*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:${local.partition}:iam::${local.acct_id}:root"]
    }
    resources = ["*"]
  }
  source_policy_documents   = local.permissions
  override_policy_documents = local.permissions
}

resource "aws_kms_replica_key" "this" {
  primary_key_arn = var.source_key_arn
  description     = var.description
  tags            = var.tags
  policy          = data.aws_iam_policy_document.this.json
}

resource "aws_kms_alias" "this" {
  count         = var.replica_alias == null ? 0 : 1
  name          = var.replica_alias
  target_key_id = aws_kms_replica_key.this.key_id
}
