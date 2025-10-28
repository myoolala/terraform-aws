output "admin_uname" {
  value = var.admin_uname
}

output "admin_default_password" {
  value = var.admin_default_password
}

output "sg_id" {
  value = aws_security_group.rds.id
}

output "connection_url" {
  value = aws_db_instance.db.address
}

output "db_name" {
  value = aws_db_instance.db.db_name
}

output "port" {
  value = aws_db_instance.db.port
}

output "instance_arn" {
  value = aws_db_instance.db.arn
}

output "instance_id" {
  value = aws_db_instance.db.id
}

output "low_storage_alam_arn" {
  value = null # aws_cloudwatch_metric_alarm.low_storage_space.arn
}