output "function_name" {
  value = module.lambda.function_name
  description = "Name of the Lambda function"
}

output "sg_id" {
  value = var.sg_config.create ? module.sg[0].id : null
  description = "Security group ID created if one was created"
}