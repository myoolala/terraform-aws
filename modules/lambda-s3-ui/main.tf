########################################################################
############                   zip bundle                   ############
########################################################################

# Archive a single file.
##
# My word this resource nearly sent me to mars while sitting on a splinter causing wooden bidet with nyan cat playing in the background in a highpass filter
# Basically, when the archive resource starts as a local module and then gets migrated to github, the state gets absolutely hosed by the nyc fire department
# causing a flurry of errors
# In my case, for a single resource I got this error trace and that was after fixing the archive file source which had to be removed from state and rebuild just to do a plan
# 11:40:06.469 STDOUT tofu: module.ui_lambda.archive_file.source: Creating...
# 11:40:06.977 STDERR tofu: ╷
# 11:40:06.977 STDERR tofu: │ Error: Provider returned invalid result object after apply
# 11:40:06.977 STDERR tofu: │ 
# 11:40:06.977 STDERR tofu: │ After the apply operation, the provider still indicated an unknown value
# 11:40:06.977 STDERR tofu: │ for module.ui_lambda.archive_file.source.id. All values must be known after
# 11:40:06.978 STDERR tofu: │ apply, so this is always a bug in the provider and should be reported in
# 11:40:06.978 STDERR tofu: │ the provider's own repository. OpenTofu will still save the other known
# 11:40:06.978 STDERR tofu: │ object values in the state.
# 11:40:06.978 STDERR tofu: ╵
# 11:40:06.978 STDERR tofu: ╷
# 11:40:06.978 STDERR tofu: │ Error: Provider returned invalid result object after apply
# 11:40:06.978 STDERR tofu: │ 
# 11:40:06.978 STDERR tofu: │ After the apply operation, the provider still indicated an unknown value
# 11:40:06.978 STDERR tofu: │ for module.ui_lambda.archive_file.source.output_base64sha256. All values
# 11:40:06.978 STDERR tofu: │ must be known after apply, so this is always a bug in the provider and
# 11:40:06.978 STDERR tofu: │ should be reported in the provider's own repository. OpenTofu will still
# 11:40:06.978 STDERR tofu: │ save the other known object values in the state.
# 11:40:06.978 STDERR tofu: ╵
# 11:40:06.979 STDERR tofu: ╷
# 11:40:06.979 STDERR tofu: │ Error: Provider returned invalid result object after apply
# 11:40:06.979 STDERR tofu: │ 
# 11:40:06.979 STDERR tofu: │ After the apply operation, the provider still indicated an unknown value
# 11:40:06.979 STDERR tofu: │ for module.ui_lambda.archive_file.source.output_base64sha512. All values
# 11:40:06.979 STDERR tofu: │ must be known after apply, so this is always a bug in the provider and
# 11:40:06.979 STDERR tofu: │ should be reported in the provider's own repository. OpenTofu will still
# 11:40:06.979 STDERR tofu: │ save the other known object values in the state.
# 11:40:06.979 STDERR tofu: ╵
# 11:40:06.979 STDERR tofu: ╷
# 11:40:06.979 STDERR tofu: │ Error: Provider returned invalid result object after apply
# 11:40:06.979 STDERR tofu: │ 
# 11:40:06.979 STDERR tofu: │ After the apply operation, the provider still indicated an unknown value
# 11:40:06.979 STDERR tofu: │ for module.ui_lambda.archive_file.source.output_md5. All values must be
# 11:40:06.979 STDERR tofu: │ known after apply, so this is always a bug in the provider and should be
# 11:40:06.979 STDERR tofu: │ reported in the provider's own repository. OpenTofu will still save the
# 11:40:06.980 STDERR tofu: │ other known object values in the state.
# 11:40:06.980 STDERR tofu: ╵
# 11:40:06.980 STDERR tofu: ╷
# 11:40:06.980 STDERR tofu: │ Error: Provider returned invalid result object after apply
# 11:40:06.980 STDERR tofu: │ 
# 11:40:06.980 STDERR tofu: │ After the apply operation, the provider still indicated an unknown value
# 11:40:06.980 STDERR tofu: │ for module.ui_lambda.archive_file.source.output_sha. All values must be
# 11:40:06.980 STDERR tofu: │ known after apply, so this is always a bug in the provider and should be
# 11:40:06.980 STDERR tofu: │ reported in the provider's own repository. OpenTofu will still save the
# 11:40:06.980 STDERR tofu: │ other known object values in the state.
# 11:40:06.980 STDERR tofu: ╵
# 11:40:06.980 STDERR tofu: ╷
# 11:40:06.980 STDERR tofu: │ Error: Provider returned invalid result object after apply
# 11:40:06.980 STDERR tofu: │ 
# 11:40:06.980 STDERR tofu: │ After the apply operation, the provider still indicated an unknown value
# 11:40:06.980 STDERR tofu: │ for module.ui_lambda.archive_file.source.output_sha256. All values must be
# 11:40:06.980 STDERR tofu: │ known after apply, so this is always a bug in the provider and should be
# 11:40:06.980 STDERR tofu: │ reported in the provider's own repository. OpenTofu will still save the
# 11:40:06.980 STDERR tofu: │ other known object values in the state.
# 11:40:06.980 STDERR tofu: ╵
# 11:40:06.980 STDERR tofu: ╷
# 11:40:06.980 STDERR tofu: │ Error: Provider returned invalid result object after apply
# 11:40:06.981 STDERR tofu: │ 
# 11:40:06.981 STDERR tofu: │ After the apply operation, the provider still indicated an unknown value
# 11:40:06.981 STDERR tofu: │ for module.ui_lambda.archive_file.source.output_sha512. All values must be
# 11:40:06.981 STDERR tofu: │ known after apply, so this is always a bug in the provider and should be
# 11:40:06.981 STDERR tofu: │ reported in the provider's own repository. OpenTofu will still save the
# 11:40:06.981 STDERR tofu: │ other known object values in the state.
# 11:40:06.981 STDERR tofu: ╵
# 11:40:06.981 STDERR tofu: ╷
# 11:40:06.981 STDERR tofu: │ Error: Provider returned invalid result object after apply
# 11:40:06.981 STDERR tofu: │ 
# 11:40:06.981 STDERR tofu: │ After the apply operation, the provider still indicated an unknown value
# 11:40:06.981 STDERR tofu: │ for module.ui_lambda.archive_file.source.output_size. All values must be
# 11:40:06.981 STDERR tofu: │ known after apply, so this is always a bug in the provider and should be
# 11:40:06.982 STDERR tofu: │ reported in the provider's own repository. OpenTofu will still save the
# 11:40:06.982 STDERR tofu: │ other known object values in the state.
# 11:40:06.982 STDERR tofu: ╵
# 11:40:06.982 STDERR tofu: ╷
# 11:40:06.982 STDERR tofu: │ Error: Archive creation error
# 11:40:06.982 STDERR tofu: │ 
# 11:40:06.982 STDERR tofu: │   with module.ui_lambda.archive_file.source,
# 11:40:06.982 STDERR tofu: │   on .terraform/modules/ui_lambda/modules/lambda-s3-ui/main.tf line 7, in resource "archive_file" "source":
# 11:40:06.982 STDERR tofu: │    7: resource "archive_file" "source" {
# 11:40:06.982 STDERR tofu: │ 
# 11:40:06.982 STDERR tofu: │ error creating archive: error archiving file: could not archive missing
# 11:40:06.982 STDERR tofu: │ file: ./lambda-function/index.js
# 11:40:06.983 STDERR tofu: ╵
# 11:40:07.049 ERROR  tofu invocation failed in ./.terragrunt-cache/V7x_XiXulF03_jd60ffo7fyoj4c/_iaOS91LrFtS14ZDx_I4Z15xvR0/terraform/modules/web-app
# 11:40:07.049 ERROR  error occurred:
## 
resource "archive_file" "source" {
  type        = "zip"
  source_file = abspath("${path.module}/lambda-function/index.js")
  output_path = abspath("${path.module}/output/lambda.zip")
}

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
  file_path     = archive_file.source.output_path

  environment_vars = {for i, v in {
      "BUCKET"                   = var.config.bucket,
      "PREFIX"                   = var.config.prefix,
      "LOG_LEVEL"                = var.config.log_level,
      "GZ_ASSETS"                = var.config.gz_assets ? "true" : "false",
      "CACHE_MAPPING"            = var.config.cache_mapping != null ? jsonencode(var.config.cache_mapping) : null,
      "SERVER_CACHE_MS"          = var.config.server_cache_ms,
      "SPA_ENABLED"              = var.config.enable_spa ? "enabled" : "disabled",
      "DEFAULT_FILE_PATH"        = var.config.default_file_path,
      "DEFAULT_RESPONSE_HEADERS" = var.config.default_response_headers != null ? jsonencode(var.config.default_response_headers) : null,
    }: i => v if v != null
  }

  # I would like to do a data policy document but that confuses open tofu since it can't ***know*** if there is something to do or not
  permissions = jsonencode({
    Version = "2012-10-17"
    Statement = concat([
      {
        Sid = "UiFileAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObject*"
        ]
        Resource = ["arn:aws:s3:::${var.config.bucket}/${trim(var.config.prefix, "/")}/*"]
      }
    ], length(var.config.storage_kms_keys) == 0 ?  [] : [
      {
        Sid = "UiKmsKeyAccess"
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