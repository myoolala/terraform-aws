output "function_arn" {
  value       = data.aws_lambda_function.this.arn
  description = "ARN of the Lambda function created"
}

output "function_name" {
  value       = module.credential_rotator.lambda_function_name
  description = "Name of the Lambda function created"
}

output "role" {
  value       = module.credential_rotator.lambda_role_arn
  description = "Role assigned to the Lambda function to add permissions to"
}

output "invoke_arn" {
  value       = module.credential_rotator.lambda_function_invoke_arn
  description = "Invoke ARN of the Lambda to connect with EventBridge"
}
