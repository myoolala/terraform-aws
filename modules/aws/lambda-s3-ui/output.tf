output "function_name" {
  value = module.lambda.function_name
}

output "load_balancer" {
  value = aws_apigatewayv2_stage.lambda.name
}

output "path_prefix" {
  value = var.path_prefix
}

output "bucket" {
  value = var.make_new_bucket ? aws_s3_bucket.code_bucket.id : var.bucket_name
}