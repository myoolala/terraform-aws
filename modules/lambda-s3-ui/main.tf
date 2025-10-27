########################################################################
############                   zip bundle                   ############
########################################################################

# Archive a single file.

resource "archive_file" "source" {
  type        = "zip"
  source_file = "${path.module}/lambda-function/index.js"
  output_path = "${path.module}/output/lambda.zip"
}

########################################################################
############                  Main lambda                   ############
########################################################################

module "sg" {
  source = "../security-group"
  count  = var.sg_config.create ? 1 : 0

  name   = "${var.lambda_name}-lambda-access"
  vpc_id = var.sg_config.vpc_id
}

########################################################################
############                  Main lambda                   ############
########################################################################

module "lambda" {
  source = "../lambda"

  function_name = var.lambda_name
  file_path     = archive_file.source.output_path

  environment_vars = {
    "BUCKET"                   = var.config.bucket,
    "PREFIX"                   = var.config.prefix,
    "LOG_LEVEL"                = var.config.log_level,
    "GZ_ASSETS"                = var.config.gz_assets ? "true" : "false",
    "CACHE_MAPPING"            = jsonencode(var.config.cache_mapping),
    "SERVER_CACHE_MS"          = var.config.server_cache_ms,
    "SPA_ENABLED"              = var.config.enable_spa ? "enabled" : "disabled",
    "DEFAULT_FILE_PATH"        = var.config.default_file_path,
    "DEFAULT_RESPONSE_HEADERS" = jsonencode(var.config.default_response_headers),
  }

  timeout = 10

  vpc_config = {
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