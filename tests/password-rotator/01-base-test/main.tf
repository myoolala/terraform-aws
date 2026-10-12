module "secrets" {
  source = "../../../modules/secrets"
  secrets = [
    {
      name  = "access_token_secret"
      value = "dummy"
    }
  ]
  recovery_window = 0
}

resource "aws_iam_user" "rotator_user" {
  name = "rotator-user-test"
}

resource "aws_iam_access_key" "rotator_key" {
  user = aws_iam_user.rotator_user.name
}

locals {
  secret_arns = [module.secrets.arn_map["access_token_secret"]]
}

module "password_rotator" {
  source               = "../../../modules/password-rotator"
  lambda_function_name = "test-password-rotator"
  secrets = {
    arns     = local.secret_arns
    kms_keys = []
  }
  default_password_config = jsonencode({
    passwordType        = "IAM_USER_ACCESS_TOKEN"
    secretStore         = "secretsmanager"
    secretStoreLocation = module.secrets.arn_map["access_token_secret"]
    secretLocation      = aws_iam_user.rotator_user.name
  })
}

# Inject credential values into the secret
resource "aws_secretsmanager_secret_version" "access_token_value" {
  secret_id = module.secrets.arn_map["access_token_secret"]
  secret_string = jsonencode({
    accessKeyId     = aws_iam_access_key.rotator_key.id
    secretAccessKey = aws_iam_access_key.rotator_key.secret
  })
}

resource "aws_lambda_invocation" "test" {
  function_name = module.password_rotator.lambda_function_name
  input         = jsonencode({ test = "ok" })
  depends_on    = [module.password_rotator, aws_secretsmanager_secret_version.access_token_value]
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Environment = "tf-integration-test"
      Billing     = "tf-integration-test"
    }
  }
}
