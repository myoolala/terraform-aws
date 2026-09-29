resource "null_resource" "install_node_modules" {
  triggers = {
    dir = "${path.module}/lambda-func"
  }

  provisioner "local-exec" {
    command = "cd ${path.module}/lambda-func \u0026\u0026 npm i --omit=dev"
    interpreter = ["/bin/bash", "-c"]
  }
}

resource "archive_file" "lambda_func" {
  type        = "zip"
  output_path = "${path.module}/lambda-func/lambda.zip"
  source_dir  = "${path.module}/lambda-func"
  excludes    = [
    "${path.module}/lambda-func/lambda.zip",
    "${path.module}/lambda-func/package.json",
    "${path.module}/lambda-func/package-lock.json",
    "${path.module}/lambda-func/test.mjs",
  ]
  depends_on  = [null_resource.install_node_modules]
}

module "lambda" {
  source        = "../lambda"
  function_name = var.lambda_function_name
  file_path     = "${path.module}/lambda-func/lambda.zip"
  runtime        = "nodejs24.x"
  handler       = "index.handler"
  vpc_config    = length(var.vpc_subnet_ids) > 0 && length(var.vpc_security_group_ids) > 0 ? {
    subnet_ids         = var.vpc_subnet_ids
    security_group_ids = var.vpc_security_group_ids
  } : null
  layers            = var.lambda_layer_arn != null ? [var.lambda_layer_arn] : []
  environment_vars  = merge(
    var.default_password_config != null ? { DEFAULT_PASSWORD_CONFIG = var.default_password_config } : {},
    var.service_rotation != null ? { SERVICE_ROTATION = var.service_rotation } : {},
    var.force_rotate_env_var != null ? { FORCE_ROTATE = var.force_rotate_env_var } : {}
  )
  memory            = var.memory
  timeout = var.lambda_timeout
  schedule = var.schedule
}
