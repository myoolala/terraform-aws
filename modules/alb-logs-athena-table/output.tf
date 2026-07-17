output "database_name" {
  value       = aws_glue_catalog_database.this.name
  description = "Name of the glue catalog database"
}

output "table_name" {
  value       = aws_glue_catalog_table.alb_access_logs.name
  description = "Name of the glue catalog table"
}

output "athena_workgroup_name" {
  value       = aws_athena_workgroup.this.name
  description = "Create Athena Workgroup name"
}

output "logs_location" {
  value       = local.logs_location
  description = "S3 URI of the source logs"
}

output "example_query" {
  value       = <<EOT
SELECT
  time,
  elb,
  client_ip,
  request_verb,
  request_url,
  elb_status_code,
  target_status_code,
  target_processing_time
FROM ${aws_glue_catalog_database.this.name}.${aws_glue_catalog_table.alb_access_logs.name}
WHERE account = '${local.acct}'
  AND region = '${local.region}'
  AND year = '2026'
  AND month = '07'
  AND day = '05'
LIMIT 100;
EOT
  description = "Example query to run inside Athena"
}

output "athena_results_location" {
  value       = local.athena_results_location
  description = "S3 URI of the Athena query results"
}