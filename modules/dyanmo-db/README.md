<!-- BEGIN_TF_DOCS -->
# DyanmoDb

Creates a DynamoDb table. That's pretty much it. All it does is wrap and automate some fields

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Requirements

No requirements.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_attributes"></a> [attributes](#input\_attributes) | List of attributes to assign to the table | <pre>list(object({<br/>    name = string<br/>    type = string<br/>  }))</pre> | `[]` | no |
| <a name="input_backups"></a> [backups](#input\_backups) | Backup configuration for the database, defaults to 7 days PIT recovery | <pre>object({<br/>    enabled                 = optional(bool, true)<br/>    recovery_period_in_days = optional(number, 7)<br/>  })</pre> | <pre>{<br/>  "enabled": true<br/>}</pre> | no |
| <a name="input_billing_mode"></a> [billing\_mode](#input\_billing\_mode) | Billing mode to apply to the table | `string` | `"ON_DEMAND"` | no |
| <a name="input_encryption"></a> [encryption](#input\_encryption) | Encryption config to use for the table | <pre>object({<br/>    enabled     = optional(bool, true)<br/>    kms_key_arn = optional(string, null)<br/>  })</pre> | n/a | yes |
| <a name="input_gsis"></a> [gsis](#input\_gsis) | List of GSI tables to create | <pre>list(object({<br/>    name               = string<br/>    hash_key           = string<br/>    range_key          = optional(string, null)<br/>    write_capacity     = optional(number, null)<br/>    read_capacity      = optional(number, null)<br/>    projection_type    = string<br/>    non_key_attributes = list(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_hash_key"></a> [hash\_key](#input\_hash\_key) | The hash key for the table. This must also be an attribute | `string` | n/a | yes |
| <a name="input_lsis"></a> [lsis](#input\_lsis) | List of Local Secondary Indexes to create if there are any | <pre>list(object({<br/>    name               = string<br/>    range_key          = string<br/>    projection_type    = string<br/>    non_key_attributes = optional(list(string), [])<br/>  }))</pre> | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | The name for the table | `string` | n/a | yes |
| <a name="input_range_key"></a> [range\_key](#input\_range\_key) | The Range/Sort key for the table if there is one | `string` | `null` | no |
| <a name="input_read_capacity"></a> [read\_capacity](#input\_read\_capacity) | Read capacity for the table if the billing mode is provisioned | `string` | `null` | no |
| <a name="input_replica_regions"></a> [replica\_regions](#input\_replica\_regions) | List of other regions to use for a global table | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Default tags to apply to all resources in the module | `map(string)` | `{}` | no |
| <a name="input_ttl_field"></a> [ttl\_field](#input\_ttl\_field) | TTL field to use from the attribute list if there is one | `string` | `null` | no |
| <a name="input_write_capacity"></a> [write\_capacity](#input\_write\_capacity) | Write capacity for the table if the billing mode is provisioned | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | ARN of the DDB table |
| <a name="output_id"></a> [id](#output\_id) | ID for the DDB table |
| <a name="output_replica_arns"></a> [replica\_arns](#output\_replica\_arns) | List of ARNs for the replica tables if there are any |  
<!-- END_TF_DOCS -->