output "lambda_arn" {
  description = "ARN of the ECR indexing Lambda"
  value       = aws_lambda_function.indexer.arn
}

output "lambda_name" {
  description = "Name of the ECR indexing Lambda"
  value       = aws_lambda_function.indexer.function_name
}
