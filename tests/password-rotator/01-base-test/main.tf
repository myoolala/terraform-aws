module "password_rotator" {
  source               = "../../../modules/password-rotator"
  lambda_function_name = "test-password-rotator"
}

# Invoke the Lambda function with a sample payload
# resource "aws_lambda_invocation" "test" {
#   function_name = module.password_rotator.lambda_function_name
#   payload       = ""
#   depends_on    = [module.password_rotator]
# }