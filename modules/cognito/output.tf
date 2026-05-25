output "pool_id" {
  value = aws_cognito_user_pool.this.id
}

output "pool_arn" {
  value = aws_cognito_user_pool.this.arn
  description = "ARN of the created user pool"
}

output "client_secret" {
  value = var.client_config != null ? aws_cognito_user_pool_client.userpool_client[0].client_secret : 0
}

output "client_id" {
  value = var.client_config != null ? aws_cognito_user_pool_client.userpool_client[0].id : 0
}