output "admin_uname" {
  value       = var.admin_uname
  description = "Admin username for the database"
}

output "admin_default_password" {
  value       = local.admin_password
  description = "Unmanaged administrator password; null for managed credentials or a snapshot restore without a supplied password."
  sensitive   = true
}

output "sg_id" {
  value       = var.create_sg ? module.rds_sg[0].id : null
  description = "The created securitygroup id if there was one"
}

output "connection_url" {
  value       = aws_db_instance.db.address
  description = "The connection url for the database"
}

output "db_name" {
  value       = aws_db_instance.db.db_name
  description = "The name for the database, this can be null"
}

output "port" {
  value       = aws_db_instance.db.port
  description = "Dabatase port"
}

output "instance_arn" {
  value       = aws_db_instance.db.arn
  description = "ARN for the database"
}

output "instance_id" {
  value       = aws_db_instance.db.id
  description = "ID for the database"
}

output "low_storage_alam_arn" {
  value       = var.free_storage_space_threshold != null ? aws_cloudwatch_metric_alarm.low_storage_space[0].arn : null
  description = "ARN of the low storage alarm"
}

output "connection_secret" {
  description = "Credential secret metadata. RDS-managed secrets contain credentials, not host/database connection metadata. Null for unmanaged snapshot restores without a supplied password."
  value = var.manage_master_user_password ? {
    arn     = try(aws_db_instance.db.master_user_secret[0].secret_arn, null)
    name    = null
    kms_key = try(aws_db_instance.db.master_user_secret[0].kms_key_id, null)
    } : (local.create_connection_secret ? {
      arn     = module.admin_connection_info[0].secret_map[0].arn
      name    = module.admin_connection_info[0].secret_map[0].name
      kms_key = module.admin_connection_info[0].kms_key
  } : null)
}

output "master_user_secret_arn" {
  description = "ARN of the RDS-managed credential secret, or null."
  value       = try(aws_db_instance.db.master_user_secret[0].secret_arn, null)
}

output "parameter_group_names" {
  description = "All pre-created parameter groups, keyed by configuration."
  value       = { for key, group in aws_db_parameter_group.params : key => group.name }
}

output "active_parameter_group_name" {
  description = "Parameter group selected for the instance."
  value       = aws_db_parameter_group.params[local.config_key].name
}
