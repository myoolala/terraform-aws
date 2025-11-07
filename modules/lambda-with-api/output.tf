output "function_name" {
  value       = module.lambda.function_name
  description = "Name of the Lambda function"
}

output "stage_name" {
  value       = aws_apigatewayv2_stage.lambda.name
  description = "Stage name for the API gateway"
}

output "path_prefix" {
  value       = var.path_prefix
  description = "Path prefix for the Lambda function"
}

output "routes" {
  value       = var.endpoints
  description = "Route endpoints the lambda supports"
}