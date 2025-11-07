output "env_map" {
  value       = [for k, v in var.secrets : { name = v.env_name, arn = aws_secretsmanager_secret.secret[k].arn } if lookup(v, "env_name", null) != null]
  description = "A mapping of the secrets from the environment variable name to its ARN in SecretsManager"
}

output "fargate_secrets" {
  value       = [for k, v in var.secrets : { name = v.env_name, valueFrom = aws_secretsmanager_secret.secret[k].arn } if lookup(v, "env_name", null) != null]
  description = "A mapping of the secrets environment variable name to its value from to support integration with ECS"
}

output "secret_map" {
  value       = [for k, v in var.secrets : { name = v.name, arn = aws_secretsmanager_secret.secret[k].arn }]
  description = "A list of the name of the secret and its ARN"
}

output "arn_map" {
  value       = { for k, v in var.secrets : v.name => aws_secretsmanager_secret.secret[k].arn }
  description = "A mapping of the name of the secret mapped to its ARN"
}

output "kms_key" {
  description = "ARN of the kms key used to encrypt the secrets"
  value       = var.create_new_key ? aws_kms_key.key[0].arn : null
}