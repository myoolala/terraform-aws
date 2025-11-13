output "function_arn" {
  value       = module.lambda.function_arn
  description = "ARN of the Lambda function created"
}

output "function_name" {
  value       = module.lambda.function_name
  description = "Name of the Lambda function created"
}

output "role" {
  value       = module.lambda.role
  description = "Role assigned to the Lambda function to add permissions to"
}

output "invoke_arn" {
  value       = module.lambda.invoke_arn
  description = "Invoke ARN of the Lambda to connect with EventBridge"
}