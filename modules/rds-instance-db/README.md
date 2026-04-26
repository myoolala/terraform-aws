<!-- BEGIN_TF_DOCS -->
# RDS

Creates an RDS database along with all required resources such as a parameter group, subnet group, security group, etc...

It does auto generate a password that will not update once created, that will be the developer's responsibility

Things to note:

- Adds an alarm for 75% usage
- Creates a randomized id for the final snapshop to support multiple database replacements
- The Parameter groups can be namespaced to support major version upgrades

Example:
```hcl
module "rds_instance" {
  source = "github.com/myoolala/terraform-aws/modules//rds-instance"

  name = "rds-instance-test"
  port = 5432
  vpc_config = {
    vpc_id = module.vpc.vpc_id
    subnets = module.vpc.compute_subnet_ids
  }
  config = {
    "default" = {
      pg_name = "test"
      engine = "postgres"
      engine_version = "18.3"
      pg_family = "postgres18"
    }
  }
}
```

[More examples can be found here](../../../tests/rds-instance-db/)

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0 |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.0.0 |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_configs"></a> [configs](#input\_configs) | Database configuration. If you notice, this it s map which is meant to allow for simpler upgrades. Upgrading a major version might require a parameter group update which would need a new group with a new name and a straight opentofu update will not suffice. This allows the upgrade to split across 2 applies for a seamless update | <pre>map(object({<br/>    pg_name = string<br/>    engine = string<br/>    engine_version = string<br/>    pg_family = string<br/>    pg_suffix = optional(string, "")<br/>    og_name = optional(string, null)<br/>    parameters = optional(list(object({<br/>      name         = string<br/>      value        = string<br/>      apply_method = optional(string, "pending-reboot")<br/>    })), [])<br/>  }))</pre> | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name for the db instance | `string` | n/a | yes |
| <a name="input_port"></a> [port](#input\_port) | Port the db instance is listening on | `number` | n/a | yes |
| <a name="input_vpc_config"></a> [vpc\_config](#input\_vpc\_config) | n/a | <pre>object({<br/>    vpc_id                 = string<br/>    subnets                = list(string)<br/>    sg_ids                 = optional(list(string), [])<br/>    ingress_cidr_whitelist = optional(list(string), [])<br/>    ingress_sg_whitelist   = optional(list(string), [])<br/>    egress_cidr_whitelist  = optional(list(string), [])<br/>    egress_sg_whitelist    = optional(list(string), [])<br/>  })</pre> | n/a | yes |
| <a name="input_admin_uname"></a> [admin\_uname](#input\_admin\_uname) | Username for the admin account on the instance | `string` | `"main"` | no |
| <a name="input_alarm_arns"></a> [alarm\_arns](#input\_alarm\_arns) | List of ARN's of the sns topics to send alerts to | `list(string)` | `[]` | no |
| <a name="input_allocated_storage"></a> [allocated\_storage](#input\_allocated\_storage) | Allocated storage in GB for the instance | `number` | `20` | no |
| <a name="input_allow_major_version_upgrade"></a> [allow\_major\_version\_upgrade](#input\_allow\_major\_version\_upgrade) | Allow major upgrades, default false | `bool` | `false` | no |
| <a name="input_auto_minor_version_upgrade"></a> [auto\_minor\_version\_upgrade](#input\_auto\_minor\_version\_upgrade) | Allow minor upgrades, default false | `bool` | `false` | no |
| <a name="input_backup_retention_period"></a> [backup\_retention\_period](#input\_backup\_retention\_period) | Number of days to store snapshot backups for | `number` | `7` | no |
| <a name="input_ca"></a> [ca](#input\_ca) | n/a | `string` | `null` | no |
| <a name="input_create_sg"></a> [create\_sg](#input\_create\_sg) | Create a new SG for the RDS database | `bool` | `true` | no |
| <a name="input_db_image"></a> [db\_image](#input\_db\_image) | Snapshot identifier of the db instance if available | `string` | `null` | no |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | Name of the db to create if applicable | `string` | `null` | no |
| <a name="input_final_snapshot_id"></a> [final\_snapshot\_id](#input\_final\_snapshot\_id) | Manually set final snapshot identifier for the instance. One is auto generated if the id is set to an empty string. null means do not set one | `string` | `null` | no |
| <a name="input_free_storage_space_threshold"></a> [free\_storage\_space\_threshold](#input\_free\_storage\_space\_threshold) | Storage level to trigger an alarm | `number` | `null` | no |
| <a name="input_instance_class"></a> [instance\_class](#input\_instance\_class) | Instance class for the db | `string` | `"db.t3.medium"` | no |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | Maintenance window for the instance | `string` | `"Fri:02:00-Fri:04:00"` | no |
| <a name="input_max_allocated_storage"></a> [max\_allocated\_storage](#input\_max\_allocated\_storage) | Max allocated storage for the isntance | `number` | `null` | no |
| <a name="input_multi_az"></a> [multi\_az](#input\_multi\_az) | Do you want a replicated db instance? | `bool` | `true` | no |
| <a name="input_network_type"></a> [network\_type](#input\_network\_type) | Network Type for the instance, defaults to IPV4 <IPV4\|DUAL> | `string` | `"IPV4"` | no |
| <a name="input_publicly_accessible"></a> [publicly\_accessible](#input\_publicly\_accessible) | n/a | `bool` | `false` | no |
| <a name="input_rds_backup_window"></a> [rds\_backup\_window](#input\_rds\_backup\_window) | Backup window for the instance | `string` | `"04:00-06:00"` | no |
| <a name="input_selected_config"></a> [selected\_config](#input\_selected\_config) | Which configuration to use from the config variable | `string` | `null` | no |
| <a name="input_skip_final_snapshot"></a> [skip\_final\_snapshot](#input\_skip\_final\_snapshot) | Skip the final snapshot on deletion | `bool` | `false` | no |
| <a name="input_storage_encrypted"></a> [storage\_encrypted](#input\_storage\_encrypted) | Store all database data encrypted at rest | `bool` | `true` | no |
| <a name="input_storage_type"></a> [storage\_type](#input\_storage\_type) | n/a | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_admin_default_password"></a> [admin\_default\_password](#output\_admin\_default\_password) | The default admin password provided to the database |
| <a name="output_admin_uname"></a> [admin\_uname](#output\_admin\_uname) | Admin username for the database |
| <a name="output_connection_url"></a> [connection\_url](#output\_connection\_url) | The connection url for the database |
| <a name="output_db_name"></a> [db\_name](#output\_db\_name) | The name for the database, this can be null |
| <a name="output_instance_arn"></a> [instance\_arn](#output\_instance\_arn) | ARN for the database |
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | ID for the database |
| <a name="output_low_storage_alam_arn"></a> [low\_storage\_alam\_arn](#output\_low\_storage\_alam\_arn) | ARN of the low storage alarm |
| <a name="output_port"></a> [port](#output\_port) | Dabatase port |
| <a name="output_sg_id"></a> [sg\_id](#output\_sg\_id) | The created securitygroup id if there was one |  
<!-- END_TF_DOCS -->