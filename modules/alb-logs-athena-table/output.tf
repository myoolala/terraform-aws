output "database_name" {
  value = aws_glue_catalog_database.this.name
}

output "table_name" {
  value = aws_glue_catalog_table.alb_access_logs.name
}

output "athena_workgroup_name" {
  value = aws_athena_workgroup.this.name
}

output "logs_location" {
  value = local.logs_location
}

output "example_query" {
  value = <<EOT
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
WHERE account = '<aws-account-id>'
  AND region = '<aws-region>'
  AND year = '2026'
  AND month = '07'
  AND day = '05'
LIMIT 100;
EOT
}

output "athena_results_location" {
  value = local.athena_results_location
}