module "cognito" {
  source = "../../../modules/cognito"

  name = "base-test"
  groups = [{
    name        = "test-1"
    description = "test-1"
    }, {
    name        = "test-2"
    description = "test-2"
    }, {
    name        = "test-3-no-role"
    description = "test-3"
  }]
  client_config = {
    name                                 = "test-for-the-test"
    callback_urls                        = ["https://example.com"]
    allowed_oauth_flows_user_pool_client = true
    allowed_oauth_flows                  = ["code", "implicit"]
    allowed_oauth_scopes                 = ["email", "openid"]
    supported_identity_providers         = ["COGNITO"]
  }
}

output "cognito" {
  sensitive = true
  value = module.cognito
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

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "=6.19.0"
    }
  }
}