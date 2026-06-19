output "role" {
  value       = var.role != null ? var.role : aws_iam_role.lambda_exec[0].arn
  description = "ARN of the role created to add permissions to"

  depends_on = [
    aws_iam_role.lambda_exec
  ]
}

output "function_name" {
  value       = aws_lambda_function.function.function_name
  description = "Name applied to the Lambda function"
}

output "function_arn" {
  value       = aws_lambda_function.function.arn
  description = "ARN of the Lambda function"
}

output "invoke_arn" {
  value       = aws_lambda_function.function.invoke_arn
  description = "The invoke ARN of the Lambda function"
}

output "log_group" {
  value = {
    name = aws_cloudwatch_log_group.logs.name
    arn  = aws_cloudwatch_log_group.logs.name
  }
  description = "The log group configuration created for the lambda function"
}