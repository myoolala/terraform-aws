data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

locals {
  acct_id           = data.aws_caller_identity.current.account_id
  region            = data.aws_region.current.region
  partition         = data.aws_partition.current.partition
}

###################################################################################################
##################                           Encrytion                           ##################
###################################################################################################
data "aws_iam_policy_document" "assume_role" {
  count = var.kms.key == "create" ? 1 : 0

  statement {
    
    effect = "Allow"
    principals {
        type = "Service"
        identifiers = ["sns.amazonaws.com"]
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
        test = "ArnLike"
        variable = "aws:SourceArn"
        values = ["arn:${local.partition}:sns:${local.region}:${local.acct_id}:${var.name}"]
    }
    condition {
        test = "StringEquals"
        variable = "aws:SourceAccount"
        values = [local.acct_id]
        }
    }

  source_policy_documents   = [var.kms.permissions]
  override_policy_documents = [var.kms.permissions]
}

module "kms_key" {
  count = var.kms.key == "create" ? 1 : 0
  source = "../kms-key"

  description             = "${var.name} bucket encryption key"
  deletion_window_in_days = var.kms.deletion_window
  alias = "alias/${var.name}-sns"
  permissions = data.aws_iam_policy_document.assume_role[0].json
}

###################################################################################################
##################                              SNS                              ##################
###################################################################################################
resource "aws_sns_topic" "topic" {
  name              = var.name
  kms_master_key_id = var.kms.key == "create" ? module.kms_key[0].key_id : var.kms.key
  display_name      = var.display_name
}

resource "aws_sns_topic_policy" "topic" {
  count = var.policy != null ? 1 : 0

  arn    = aws_sns_topic.topic.arn
  policy = var.policy
}