data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

locals {
  lambda_layer_arn = var.existing_code != null ? var.existing_code : aws_lambda_layer_version.hooks_layer[0].arn
}

# Create a Lambda layer containing custom hooks if not supplied
resource "archive_file" "hooks_zip" {
  type        = "zip"
  output_path = "${path.module}/hooks.zip"
  source_file = "${path.module}/lambda-layer/hooks.mjs"
}

resource "aws_lambda_layer_version" "hooks_layer" {
  count               = var.existing_code == null ? 1 : 0
  layer_name          = "${var.name}-hooks"
  compatible_runtimes = ["nodejs24.x", "nodejs20.x"]
  description         = "Custom hooks for rotate-smtp-credentials"
  filename            = archive_file.hooks_zip.output_path
}

module "credential_rotator" {
  source                 = "../credential-rotator"

  lambda_function_name   = var.name
  lambda_layer_arn       = local.lambda_layer_arn
  vpc_subnet_ids         = var.vpc_config != null ? var.vpc_config.subnets : []
  vpc_security_group_ids = var.vpc_config != null && var.vpc_config.security_groups != null ? var.vpc_config.security_groups : []
  permissions            = var.permissions
  schedule               = var.schedule
  memory                 = var.memory
  timeout                = var.timeout
  environment_vars = merge({
      IAM_USER               = var.iam_user
      SSM_PARAMETER          = var.ssm_parameter != null ? var.ssm_parameter : ""
      SECRETS_MANAGER_SECRET = var.secretsmanager_secret != null  ? var.secretsmanager_secret : ""
      SNS_TOPIC              = var.sns_topic != null ? var.sns_topic : ""
    },
    var.additonal_environment_vars
  )
}

# IAM policy to give Lambda access to SNS, SSM, Secrets Manager and IAM write for login profile
# This is a data source so Terraform can serialize the policy for attachment

data "aws_iam_policy_document" "add_lifecycle_permissions" {
  dynamic "statement" {
    for_each = var.sns_topic != null ? [1] : []
    content {
      sid       = "AllowSNSPublish"
      effect    = "Allow"
      actions   = ["sns:Publish"]
      resources = [var.sns_topic]
    }
  }

  dynamic "statement" {
    for_each = var.ssm_parameter != null ? [1] : []
    content {
      sid       = "AllowSSMPut"
      effect    = "Allow"
      actions   = ["ssm:PutParameter"]
      resources = ["arn:aws:ssm:${data.aws_region.current.region}:*:parameter${var.ssm_parameter}"]
    }
  }

  dynamic "statement" {
    for_each = var.secretsmanager_secret != null ? [1] : []
    content {
      sid       = "AllowSecretsAccess"
      effect    = "Allow"
      actions   = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:PutSecretValue"
      ]
      resources = [var.secretsmanager_secret]
    }
  }

  statement {
    sid       = "AllowIAMWrite"
    effect    = "Allow"
    actions   = [
      "iam:ListAccessKeys",
      "iam:CreateAccessKey",
      "iam:DeleteAccessKey",
    ]
    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${var.iam_user}"]
  }
}

resource "aws_iam_role_policy" "lifecycle_permissions" {
  role   = module.credential_rotator.lambda_role_name
  policy = data.aws_iam_policy_document.add_lifecycle_permissions.json
}
