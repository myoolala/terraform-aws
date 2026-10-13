output "lambda_function_name" {
  description = "Name of the created Lambda function."
  value       = module.lambda.function_name
}

output "lambda_function_invoke_arn" {
  description = "Invoke ARN of the created Lambda function."
  value       = module.lambda.invoke_arn
}

output "lambda_security_group_ids" {
  description = "List of security group IDs attached to the Lambda function if any."
  value       = var.vpc_security_group_ids
}

output "lambda_role_name" {
  description = "The name of the IAM role used by the Lambda function."
  value       = module.lambda.role_name
}

output "lambda_role_arn" {
  description = "ARN of the IAM role used by the Lambda function."
  value       = module.lambda.role
}

output "lambda_log_group" {
  description = "Log group configuration created for the Lambda function."
  value       = module.lambda.log_group
}


