output "env_map" {
  value = [for k, v in var.secrets : { name = v.env_name, arn = aws_secretsmanager_secret.secret[k].arn } if lookup(v, "env_name", null) != null]
}

output "fargate_secrets" {
  value = [for k, v in var.secrets : { name = v.env_name, valueFrom = aws_secretsmanager_secret.secret[k].arn } if lookup(v, "env_name", null) != null]
}

output "secret_map" {
  value = [for k, v in var.secrets : { name = v.name, arn = aws_secretsmanager_secret.secret[k].arn }]
}

output "arn_map" {
  value = { for k, v in var.secrets : v.name => aws_secretsmanager_secret.secret[k].arn }
}

output "kms_key" {
  description = "ARN of the kms key used to encrypt the secrets"
  value       = var.create_new_key ? aws_kms_key.key[0].arn : null
}