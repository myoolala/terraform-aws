data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}

locals {
  region = data.aws_region.current.region
  partition = data.aws_partition.current.partition
  acct = data.aws_caller_identity.current.account_id
}

resource "aws_kms_key" "key" {
  count = var.create_new_key ? 1 : 0

  description             = "Secrets key"
  deletion_window_in_days = 7

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Action = "kms:*"
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:${local.partition}:iam::${local.acct}:root"
          ]
        }
        # Gross and misleading I know, but it has to be star
        # As it is attached to a single secret and AWS needs a resource line
        Resource = "*"
      }
    ]
  })
}

resource "aws_secretsmanager_secret" "secret" {
  count = length(var.secrets)

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "secretsmanager:*"
        Effect = "Allow"
        Principal = {
          AWS = "arn:${local.partition}:sts::${data.aws_caller_identity.current.account_id}:federated-user/root"
        }
        # Gross and misleading I know, but it has to be star
        # As it is attached to a single secret and AWS needs a resource line
        Resource = "*"
      }
    ]
  })
  name                    = var.secrets[count.index].name
  kms_key_id              = var.create_new_key ? aws_kms_key.key[0].key_id : var.kms_key_id
  recovery_window_in_days = var.recovery_window
}

resource "aws_secretsmanager_secret_version" "secret" {
  count = length(var.secrets)

  secret_id     = aws_secretsmanager_secret.secret[count.index].id
  secret_string = var.secrets[count.index].value
}