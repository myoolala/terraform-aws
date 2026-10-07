module "password_rotator" {
  source               = "../../../modules/password-rotator"
  lambda_function_name = "test-password-rotator"
}
