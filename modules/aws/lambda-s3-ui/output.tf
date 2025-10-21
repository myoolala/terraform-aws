output "function_name" {
  value = module.lambda.function_name
}

output "sg_id" {
  value = var.sg_config.create ? module.sg.id : null
}