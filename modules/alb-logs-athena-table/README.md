<!-- BEGIN_TF_DOCS -->
# ALB Logs Athena Table

Creates an Athena table to index and make available ALB access logs for query capabilities

## Example: 

```hcl
module "alb_logs_athena" {
  source = "github.com/myoolala/terraform-aws//modules/alb-logs-athena-table"

  name                  = "app-alb-logs"
  alb_logs_bucket       = "my-alb-log-bucket"
  alb_logs_prefix       = "alb"
}
```

[Examples can be found here](../../tests/alb-logs-athena-table/)

## Example queries:

```sql
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
```

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.53.0 |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.53.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_logs_bucket"></a> [alb\_logs\_bucket](#input\_alb\_logs\_bucket) | S3 bucket containing ALB access logs. | `string` | n/a | yes |
| <a name="input_alb_logs_prefix"></a> [alb\_logs\_prefix](#input\_alb\_logs\_prefix) | S3 prefix where ALB access logs are stored. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name prefix for Athena and Glue resources. | `string` | n/a | yes |
| <a name="input_athena_results_bucket"></a> [athena\_results\_bucket](#input\_athena\_results\_bucket) | S3 bucket for Athena query results. Leave null to create a new bucket | `string` | `null` | no |
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | Glue database name. | `string` | `null` | no |
| <a name="input_table_name"></a> [table\_name](#input\_table\_name) | Glue table name. | `string` | `"alb_access_logs"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_athena_results_location"></a> [athena\_results\_location](#output\_athena\_results\_location) | n/a |
| <a name="output_athena_workgroup_name"></a> [athena\_workgroup\_name](#output\_athena\_workgroup\_name) | n/a |
| <a name="output_database_name"></a> [database\_name](#output\_database\_name) | n/a |
| <a name="output_example_query"></a> [example\_query](#output\_example\_query) | n/a |
| <a name="output_logs_location"></a> [logs\_location](#output\_logs\_location) | n/a |
| <a name="output_table_name"></a> [table\_name](#output\_table\_name) | n/a |  
<!-- END_TF_DOCS -->