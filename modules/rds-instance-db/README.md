<!-- BEGIN_TF_DOCS -->
# RDS DB Instance

Creates an RDS instance, subnet group, and parameter groups. Security groups,
a storage alarm, and unmanaged credential storage are optional.

- `configs` defines engine versions and parameter groups; `selected_config`
  selects the active configuration. All configured parameter groups are created.
- Use `manage_master_user_password = true` for RDS-managed credentials.
- SQL Server Express supports single-AZ only. Create application databases
  after provisioning.
- Supply security parameters, audit options, encryption keys, and monitoring
  settings through the caller.

## Example

```hcl
module "db" {
  source = "github.com/myoolala/terraform-aws/modules//rds-instance-db?ref=main"

  name                        = "app-dev-db"
  port                        = 5432
  multi_az                    = false
  instance_class              = "db.t3.medium"
  allocated_storage           = 20
  storage_type                = "gp3"
  storage_encrypted           = true
  kms_key_id                  = var.database_kms_key_arn
  manage_master_user_password  = true
  master_user_secret_kms_key_id = var.secrets_kms_key_arn
  selected_config             = "postgres-16"

  vpc_config = {
    vpc_id  = var.vpc_id
    subnets = var.private_database_subnet_ids
    sg_ids  = [var.database_security_group_id]
  }
  create_sg = false

  configs = {
    postgres-16 = {
      engine                 = "postgres"
      engine_version         = var.postgres_engine_version
      parameter_group_name   = "app-dev-db-postgres-16-v1"
      parameter_group_family = "postgres16"
      parameters = [
        { name = "rds.force_ssl", value = "1" }
      ]
    }
  }
}
```

Use an exact PostgreSQL 16 engine version available in your region.
Pin the module source to a reviewed commit containing these changes.

[Module tests](./tests/) · [Integration examples](../../tests/rds-instance-db/)

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.0.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0 |
| <a name="provider_null"></a> [null](#provider\_null) | >= 3.0.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_admin_connection_info"></a> [admin\_connection\_info](#module\_admin\_connection\_info) | ../secrets | n/a |
| <a name="module_rds_sg"></a> [rds\_sg](#module\_rds\_sg) | ../security-group | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_metric_alarm.low_storage_space](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_db_instance.db](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_db_parameter_group.params](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_parameter_group) | resource |
| [aws_db_subnet_group.subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [null_resource.snapshot_id_trigger](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_string.default_pw](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [random_uuid.snapshot](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_configs"></a> [configs](#input\_configs) | Engine configurations. All parameter groups are created; selected\_config chooses the active engine and group. Keep names unique across configurations. | <pre>map(object({<br/>    parameter_group_name   = optional(string, null)<br/>    engine                 = string<br/>    engine_version         = string<br/>    parameter_group_family = string<br/>    parameter_group_suffix = optional(string, "")<br/>    option_group_name      = optional(string, null)<br/>    parameters = optional(list(object({<br/>      name         = string<br/>      value        = string<br/>      apply_method = optional(string, "pending-reboot")<br/>    })), [])<br/>  }))</pre> | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name for the db instance | `string` | n/a | yes |
| <a name="input_port"></a> [port](#input\_port) | Port the db instance is listening on | `number` | n/a | yes |
| <a name="input_vpc_config"></a> [vpc\_config](#input\_vpc\_config) | n/a | <pre>object({<br/>    vpc_id                 = string<br/>    subnets                = list(string)<br/>    sg_ids                 = optional(list(string), [])<br/>    ingress_cidr_whitelist = optional(list(string), [])<br/>    ingress_sg_whitelist   = optional(list(string), [])<br/>    egress_cidr_whitelist  = optional(list(string), [])<br/>    egress_sg_whitelist    = optional(list(string), [])<br/>  })</pre> | n/a | yes |
| <a name="input_admin_uname"></a> [admin\_uname](#input\_admin\_uname) | Username for the admin account on the instance | `string` | `"main"` | no |
| <a name="input_alarm_arns"></a> [alarm\_arns](#input\_alarm\_arns) | List of ARN's of the sns topics to send alerts to | `list(string)` | `[]` | no |
| <a name="input_allocated_storage"></a> [allocated\_storage](#input\_allocated\_storage) | Allocated storage in GB for the instance | `number` | `20` | no |
| <a name="input_allow_major_version_upgrade"></a> [allow\_major\_version\_upgrade](#input\_allow\_major\_version\_upgrade) | Allow major upgrades, default false | `bool` | `false` | no |
| <a name="input_apply_immediately"></a> [apply\_immediately](#input\_apply\_immediately) | Apply changes immediately instead of during the maintenance window. | `bool` | `false` | no |
| <a name="input_auto_minor_version_upgrade"></a> [auto\_minor\_version\_upgrade](#input\_auto\_minor\_version\_upgrade) | Allow minor upgrades, default false | `bool` | `false` | no |
| <a name="input_backup_retention_period"></a> [backup\_retention\_period](#input\_backup\_retention\_period) | Number of days to store snapshot backups for | `number` | `7` | no |
| <a name="input_ca"></a> [ca](#input\_ca) | n/a | `string` | `null` | no |
| <a name="input_copy_tags_to_snapshot"></a> [copy\_tags\_to\_snapshot](#input\_copy\_tags\_to\_snapshot) | Copy database instance tags to snapshots. | `bool` | `true` | no |
| <a name="input_create_sg"></a> [create\_sg](#input\_create\_sg) | Create a new SG for the RDS database | `bool` | `true` | no |
| <a name="input_db_image"></a> [db\_image](#input\_db\_image) | Snapshot identifier of the db instance if available | `string` | `null` | no |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | Name of the db to create if applicable | `string` | `null` | no |
| <a name="input_delete_automated_backups"></a> [delete\_automated\_backups](#input\_delete\_automated\_backups) | Whether automated backups are deleted with the instance. | `bool` | `false` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Protect the instance from deletion until explicitly disabled. | `bool` | `true` | no |
| <a name="input_enabled_cloudwatch_logs_exports"></a> [enabled\_cloudwatch\_logs\_exports](#input\_enabled\_cloudwatch\_logs\_exports) | Engine-supported log types to export. SQL Server supports error and agent. | `set(string)` | `[]` | no |
| <a name="input_final_snapshot_id"></a> [final\_snapshot\_id](#input\_final\_snapshot\_id) | Manually set final snapshot identifier for the instance. One is auto generated if the id is set to an empty string. null means do not set one | `string` | `null` | no |
| <a name="input_free_storage_space_threshold"></a> [free\_storage\_space\_threshold](#input\_free\_storage\_space\_threshold) | Storage level to trigger an alarm | `number` | `null` | no |
| <a name="input_instance_class"></a> [instance\_class](#input\_instance\_class) | Instance class for the db | `string` | `"db.t3.medium"` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | KMS key ARN for encrypted database storage; snapshot restores inherit their source key. | `string` | `null` | no |
| <a name="input_license_model"></a> [license\_model](#input\_license\_model) | License model. Use license-included for RDS SQL Server. | `string` | `null` | no |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | Maintenance window for the instance | `string` | `"Fri:02:00-Fri:04:00"` | no |
| <a name="input_manage_master_user_password"></a> [manage\_master\_user\_password](#input\_manage\_master\_user\_password) | Use RDS-managed Secrets Manager credentials. Explicitly enable for the secure caller configuration. | `bool` | `false` | no |
| <a name="input_master_user_secret_kms_key_id"></a> [master\_user\_secret\_kms\_key\_id](#input\_master\_user\_secret\_kms\_key\_id) | KMS key ARN for the RDS-managed master secret. | `string` | `null` | no |
| <a name="input_max_allocated_storage"></a> [max\_allocated\_storage](#input\_max\_allocated\_storage) | Max allocated storage for the isntance | `number` | `null` | no |
| <a name="input_monitoring_interval"></a> [monitoring\_interval](#input\_monitoring\_interval) | Enhanced Monitoring interval in seconds; zero disables it. | `number` | `0` | no |
| <a name="input_monitoring_role_arn"></a> [monitoring\_role\_arn](#input\_monitoring\_role\_arn) | IAM role ARN for Enhanced Monitoring. | `string` | `null` | no |
| <a name="input_multi_az"></a> [multi\_az](#input\_multi\_az) | Do you want a replicated db instance? | `bool` | `true` | no |
| <a name="input_network_type"></a> [network\_type](#input\_network\_type) | Network Type for the instance, defaults to IPV4 <IPV4\|DUAL> | `string` | `"IPV4"` | no |
| <a name="input_password"></a> [password](#input\_password) | Optional administrator password for unmanaged credentials. Stored in Terraform state. | `string` | `null` | no |
| <a name="input_publicly_accessible"></a> [publicly\_accessible](#input\_publicly\_accessible) | n/a | `bool` | `false` | no |
| <a name="input_rds_backup_window"></a> [rds\_backup\_window](#input\_rds\_backup\_window) | Backup window for the instance | `string` | `"04:00-06:00"` | no |
| <a name="input_secret_recovery_window_in_days"></a> [secret\_recovery\_window\_in\_days](#input\_secret\_recovery\_window\_in\_days) | Recovery window for the legacy unmanaged connection secret. | `number` | `30` | no |
| <a name="input_selected_config"></a> [selected\_config](#input\_selected\_config) | Which configuration to use from the config variable | `string` | `null` | no |
| <a name="input_skip_final_snapshot"></a> [skip\_final\_snapshot](#input\_skip\_final\_snapshot) | Skip the final snapshot on deletion | `bool` | `false` | no |
| <a name="input_storage_encrypted"></a> [storage\_encrypted](#input\_storage\_encrypted) | Store all database data encrypted at rest | `bool` | `true` | no |
| <a name="input_storage_type"></a> [storage\_type](#input\_storage\_type) | n/a | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to directly managed resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_active_parameter_group_name"></a> [active\_parameter\_group\_name](#output\_active\_parameter\_group\_name) | Parameter group selected for the instance. |
| <a name="output_admin_default_password"></a> [admin\_default\_password](#output\_admin\_default\_password) | Unmanaged administrator password; null for managed credentials or a snapshot restore without a supplied password. |
| <a name="output_admin_uname"></a> [admin\_uname](#output\_admin\_uname) | Admin username for the database |
| <a name="output_connection_secret"></a> [connection\_secret](#output\_connection\_secret) | Credential secret metadata. RDS-managed secrets contain credentials, not host/database connection metadata. Null for unmanaged snapshot restores without a supplied password. |
| <a name="output_connection_url"></a> [connection\_url](#output\_connection\_url) | The connection url for the database |
| <a name="output_db_name"></a> [db\_name](#output\_db\_name) | The name for the database, this can be null |
| <a name="output_instance_arn"></a> [instance\_arn](#output\_instance\_arn) | ARN for the database |
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | ID for the database |
| <a name="output_low_storage_alam_arn"></a> [low\_storage\_alam\_arn](#output\_low\_storage\_alam\_arn) | ARN of the low storage alarm |
| <a name="output_master_user_secret_arn"></a> [master\_user\_secret\_arn](#output\_master\_user\_secret\_arn) | ARN of the RDS-managed credential secret, or null. |
| <a name="output_parameter_group_names"></a> [parameter\_group\_names](#output\_parameter\_group\_names) | All pre-created parameter groups, keyed by configuration. |
| <a name="output_port"></a> [port](#output\_port) | Dabatase port |
| <a name="output_sg_id"></a> [sg\_id](#output\_sg\_id) | The created securitygroup id if there was one |
<!-- END_TF_DOCS -->