########################################################################
############                Security Group                  ############
########################################################################

locals {
  new_sg_egress_rules = concat(length(var.sg_config.egress_cidrs) == 0 ? [] : [{
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.sg_config.egress_cidrs
    }], [for i, v in var.sg_config.egress_sgs : {
    from_port                = 443
    to_port                  = 443
    protocol                 = "tcp"
    source_security_group_id = v
  }])
}

module "sg" {
  source = "../security-group"
  count  = var.sg_config.create ? 1 : 0

  name   = "${var.lambda_name}-lambda-access"
  vpc_id = var.sg_config.vpc_id
}

########################################################################
############                  Permissions                   ############
########################################################################

data "aws_iam_policy_document" "perms" {
  statement {
    sid = "S3UiFileAccess"

    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObject*"
    ]
    resources = ["arn:aws:s3:::${var.config.bucket}/${var.config.prefix}/*"]
  }

  dynamic "statement" {
    for_each = length(var.config.storage_kms_keys) > 0 ? [1] : []

    content {
      sid = "S3UiFileAccess"

      effect = "Allow"
      actions = [
        "kms:Decrypt"
      ]
      resources = [var.config.storage_kms_keys]
    }
  }
}

########################################################################
############                  Main lambda                   ############
########################################################################

module "lambda" {
  source = "../lambda"

  function_name = var.lambda_name
  file_path     = var.file_path
  bucket        = var.bucket
  key           = var.key

  environment_vars = { for i, v in {
    "BUCKET"                   = var.config.bucket,
    "PREFIX"                   = var.config.prefix,
    "LOG_LEVEL"                = var.config.log_level,
    "GZ_ASSETS"                = var.config.gz_assets ? "true" : "false",
    "CACHE_MAPPING"            = var.config.cache_mapping != null ? jsonencode(var.config.cache_mapping) : null,
    "SERVER_CACHE_MS"          = var.config.server_cache_ms,
    "SPA_ENABLED"              = var.config.enable_spa ? "enabled" : "disabled",
    "DEFAULT_FILE_PATH"        = var.config.default_file_path,
    "DEFAULT_RESPONSE_HEADERS" = var.config.default_response_headers != null ? jsonencode(var.config.default_response_headers) : null,
    } : i => v if v != null
  }

  # I would like to do a data policy document but that confuses open tofu since it can't ***know*** if there is something to do or not
  permissions = jsonencode({
    Version = "2012-10-17"
    Statement = concat([
      {
        Sid    = "UiFileAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObject*"
        ]
        Resource = ["arn:aws:s3:::${var.config.bucket}/${trim(var.config.prefix, "/")}/*"]
      }
      ], length(var.config.storage_kms_keys) == 0 ? [] : [
      {
        Sid    = "UiKmsKeyAccess"
        Effect = "Allow"
        Action = [
          "kms:Decrypt"
        ]
        Resource = [var.config.storage_kms_keys]
      }
    ])
  })
  timeout = 10

  vpc_config = var.vpc_config == null ? null : {
    subnet_ids         = var.vpc_config.subnets
    security_group_ids = concat(var.vpc_config.sg_ids, module.sg[*].id)
  }
}

resource "aws_lambda_permission" "lambda_perms" {
  statement_id  = "load-balancer-invoke"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.function_arn
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = var.alb_tg_arn
}

resource "aws_lb_target_group_attachment" "alb_connection" {
  target_group_arn = var.alb_tg_arn
  target_id        = module.lambda.function_arn

  depends_on = [
    aws_lambda_permission.lambda_perms
  ]
}