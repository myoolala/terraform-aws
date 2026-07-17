<!-- BEGIN_TF_DOCS -->
# ALB Logs Athena Table

Creates an Athena table to index and make available ALB access logs for query capabilities. Also offers the ability to overwrite the columns mainly to easily support WAFs

## Example: 

```hcl
module "alb_logs_athena" {
  source = "github.com/myoolala/terraform-aws//modules/alb-logs-athena-table"

  name                  = "app-alb-logs"
  database_name         = "app_ingress_logs"
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
FROM app_ingress_logs.alb_access_logs
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
| <a name="input_additional_columns"></a> [additional\_columns](#input\_additional\_columns) | Additional columns in order to match to the regex at the end of the main columns. Intention is to make adding columns easier | <pre>list(object({<br/>    name = string<br/>    type = optional(string, "string")<br/>  }))</pre> | `{}` | no |
| <a name="input_athena_results_bucket"></a> [athena\_results\_bucket](#input\_athena\_results\_bucket) | S3 bucket for Athena query results. Leave null to create a new bucket | `string` | `null` | no |
| <a name="input_columns"></a> [columns](#input\_columns) | Columns in order to match to the regex | <pre>map(object({<br/>    type = optional(string, "string")<br/>  }))</pre> | <pre>[<br/>  {<br/>    "name": "type"<br/>  },<br/>  {<br/>    "name": "time"<br/>  },<br/>  {<br/>    "name": "elb"<br/>  },<br/>  {<br/>    "name": "client_ip"<br/>  },<br/>  {<br/>    "name": "client_port",<br/>    "type": "int"<br/>  },<br/>  {<br/>    "name": "target_ip"<br/>  },<br/>  {<br/>    "name": "target_port"<br/>  },<br/>  {<br/>    "name": "request_processing_time",<br/>    "type": "double"<br/>  },<br/>  {<br/>    "name": "target_processing_time",<br/>    "type": "double"<br/>  },<br/>  {<br/>    "name": "response_processing_time",<br/>    "type": "double"<br/>  },<br/>  {<br/>    "name": "elb_status_code",<br/>    "type": "int"<br/>  },<br/>  {<br/>    "name": "target_status_code"<br/>  },<br/>  {<br/>    "name": "received_bytes",<br/>    "type": "bigint"<br/>  },<br/>  {<br/>    "name": "sent_bytes",<br/>    "type": "bigint"<br/>  },<br/>  {<br/>    "name": "request_verb"<br/>  },<br/>  {<br/>    "name": "request_url"<br/>  },<br/>  {<br/>    "name": "request_proto"<br/>  },<br/>  {<br/>    "name": "user_agent"<br/>  },<br/>  {<br/>    "name": "ssl_cipher"<br/>  },<br/>  {<br/>    "name": "ssl_protocol"<br/>  },<br/>  {<br/>    "name": "target_group_arn"<br/>  },<br/>  {<br/>    "name": "trace_id"<br/>  },<br/>  {<br/>    "name": "domain_name"<br/>  },<br/>  {<br/>    "name": "chosen_cert_arn"<br/>  },<br/>  {<br/>    "name": "matched_rule_priority"<br/>  },<br/>  {<br/>    "name": "request_creation_time"<br/>  },<br/>  {<br/>    "name": "actions_executed"<br/>  },<br/>  {<br/>    "name": "redirect_url"<br/>  },<br/>  {<br/>    "name": "lambda_error_reason"<br/>  },<br/>  {<br/>    "name": "target_port_list"<br/>  },<br/>  {<br/>    "name": "target_status_code_list"<br/>  },<br/>  {<br/>    "name": "classification"<br/>  },<br/>  {<br/>    "name": "classification_reason"<br/>  },<br/>  {<br/>    "name": "conn_trace_id"<br/>  },<br/>  {<br/>    "name": "transformed_host"<br/>  },<br/>  {<br/>    "name": "transformed_uri"<br/>  },<br/>  {<br/>    "name": "request_transform_status"<br/>  }<br/>]</pre> | no |
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | Glue database name. | `string` | `null` | no |
| <a name="input_partition_keys"></a> [partition\_keys](#input\_partition\_keys) | Parition keys to attach to the table | <pre>list(object({<br/>    name = string<br/>    type = optional(string, "string")<br/>  }))</pre> | <pre>[<br/>  {<br/>    "name": "account"<br/>  },<br/>  {<br/>    "name": "region"<br/>  },<br/>  {<br/>    "name": "year"<br/>  },<br/>  {<br/>    "name": "month"<br/>  },<br/>  {<br/>    "name": "day"<br/>  }<br/>]</pre> | no |
| <a name="input_ser_de_info_regex"></a> [ser\_de\_info\_regex](#input\_ser\_de\_info\_regex) | Primary regex used to parse the logs. This would probably change with a WAF attached to the ALB | `string` | `"([^ ]+) ([^ ]+) ([^ ]+) ([^: ]+):([0-9]+) ([^ ]+)(?::([0-9]+))? ([^ ]+) ([^ ]+) ([^ ]+) ([^ ]+) ([^ ]+) ([^ ]+) ([^ ]+) \"([^ ]+) ([^\"]*) ([^ ]+)\" \"([^\"]*)\" ([^ ]+) ([^ ]+) ([^ ]+) \"([^\"]*)\" \"([^\"]*)\" \"([^\"]*)\" ([^ ]+) ([^ ]+) \"([^\"]*)\" \"([^\"]*)\" \"([^\"]*)\" \"([^\"]*)\" \"([^\"]*)\" \"([^\"]*)\" \"([^\"]*)\" ([^ ]+) \"([^\"]*)\" \"([^\"]*)\" \"([^\"]*)\""` | no |
| <a name="input_table_name"></a> [table\_name](#input\_table\_name) | Glue table name. | `string` | `"alb_access_logs"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_athena_results_location"></a> [athena\_results\_location](#output\_athena\_results\_location) | S3 URI of the Athena query results |
| <a name="output_athena_workgroup_name"></a> [athena\_workgroup\_name](#output\_athena\_workgroup\_name) | Create Athena Workgroup name |
| <a name="output_database_name"></a> [database\_name](#output\_database\_name) | Name of the glue catalog database |
| <a name="output_example_query"></a> [example\_query](#output\_example\_query) | Example query to run inside Athena |
| <a name="output_logs_location"></a> [logs\_location](#output\_logs\_location) | S3 URI of the source logs |
| <a name="output_table_name"></a> [table\_name](#output\_table\_name) | Name of the glue catalog table |  
<!-- END_TF_DOCS -->