resource "archive_file" "hooks_zip" {
  type        = "zip"
  output_path = "${path.root}/hooks.zip"
  source_file = "${path.root}/hooks.mjs"
}

resource "aws_lambda_layer_version" "hooks_layer" {
  layer_name          = "password-rotator-hooks"
  compatible_runtimes = ["nodejs20.x"]
  description         = "Layer containing custom hooks for password-rotator"
  filename            = archive_file.hooks_zip.output_path
}

module "password_rotator" {
  source               = "../../../modules/password-rotator"
  lambda_function_name = "test-password-rotator"
  lambda_layer_arn     = aws_lambda_layer_version.hooks_layer.arn
}

# Invoke the Lambda function with a sample payload
# resource "aws_lambda_invocation" "test" {
#   function_name = module.password_rotator.lambda_function_name
#   payload       = ""
#   depends_on    = [module.password_rotator]
# }