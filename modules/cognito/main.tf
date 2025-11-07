resource "aws_cognito_user_pool" "this" {
  name = var.name

  tags = var.tags
}

resource "aws_cognito_user_group" "main" {
  count = length(var.groups)

  name         = var.groups[count.index].name
  user_pool_id = aws_cognito_user_pool.this.id
  description  = var.groups[count.index].description
  precedence   = var.groups[count.index].precidence
  role_arn     = var.groups[count.index].role_arn
}

resource "aws_cognito_user_pool_client" "userpool_client" {
  count = var.client_config != null ? 1 : 0

  name                                 = var.client_config.name
  user_pool_id                         = aws_cognito_user_pool.this.id
  callback_urls                        = var.client_config.callback_urls
  allowed_oauth_flows_user_pool_client = var.client_config.allowed_oauth_flows_user_pool_client
  allowed_oauth_flows                  = var.client_config.allowed_oauth_flows
  allowed_oauth_scopes                 = var.client_config.allowed_oauth_scopes
  supported_identity_providers         = var.client_config.supported_identity_providers
}

resource "aws_cognito_user_pool" "pool" {
  name = "pool"
}