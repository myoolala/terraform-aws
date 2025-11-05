output "admin_uname" {
  value = var.admin_uname
  description = "Admin username for the database"
}

output "admin_default_password" {
  value = var.admin_default_password
  description = "The default admin password provided to the database"
}

output "sg_id" {
  value = local.create_new_sg ? module.rds_sg[0].id : null
  description = "The created securitygroup id if there was one"
}

output "connection_url" {
  value = aws_db_instance.db.address
  description = "The connection url for the database"
}

output "db_name" {
  value = aws_db_instance.db.db_name
  description = "The name for the database, this can be null"
}

output "port" {
  value = aws_db_instance.db.port
  description = "Dabatase port"
}

output "instance_arn" {
  value = aws_db_instance.db.arn
  description = "ARN for the database"
}

output "instance_id" {
  value = aws_db_instance.db.id
  description = "ID for the database"
}

output "low_storage_alam_arn" {
  value = var.free_storage_space_threshold != null ? aws_cloudwatch_metric_alarm.low_storage_space[0].arn : null
  description = "ARN of the low storage alarm"
}