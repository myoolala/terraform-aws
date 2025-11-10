data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

locals {
  acct_id   = data.aws_caller_identity.current.account_id
  region    = data.aws_region.current.region
  partition = data.aws_partition.current.partition
}

###################################################################################################
##################                           Encrytion                           ##################
###################################################################################################
data "aws_iam_policy_document" "this" {
  count = var.kms.key == "create" ? 1 : 0

  statement {

    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["sqs.amazonaws.com"]
    }

    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    resources = ["*"]
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:${local.partition}:sqs:${local.region}:${local.acct_id}:${var.name}"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [local.acct_id]
    }
  }

  source_policy_documents   = [var.kms.permissions]
  override_policy_documents = [var.kms.permissions]
}

module "kms_key" {
  count  = var.kms.key == "create" ? 1 : 0
  source = "../kms-key"

  description             = "${var.name} bucket encryption key"
  deletion_window_in_days = var.kms.deletion_window
  alias                   = "alias/${var.name}-sqs"
  permissions             = data.aws_iam_policy_document.this[0].json
}

###################################################################################################
##################                              SQS                              ##################
###################################################################################################

resource "aws_sqs_queue" "this" {
  name                       = var.name
  delay_seconds              = var.delay_seconds
  max_message_size           = var.max_message_size
  message_retention_seconds  = var.message_retention_seconds
  receive_wait_time_seconds  = var.receive_wait_time_seconds
  visibility_timeout_seconds = var.visibility_timeout_seconds
  kms_master_key_id          = var.kms.key == "create" ? module.kms_key[0].key_arn : var.kms.key
}

resource "aws_sqs_queue_policy" "topic" {
  count = var.policy != null ? 1 : 0

  queue_url = aws_sqs_queue.this.url
  policy    = var.policy
}