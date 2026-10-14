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
  description         = "Custom hooks for rotate-admin-rds-pw"
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
  memory                 = 256
}

# Data source to fetch Lambda details for function_arn

data "aws_lambda_function" "this" {
  function_name = module.credential_rotator.lambda_function_name
}
