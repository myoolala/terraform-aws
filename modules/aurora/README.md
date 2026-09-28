<!-- BEGIN_TF_DOCS -->
# Aurora Cluster

Creates an Auora cluster for either serverless or provisioned. Nice replacement for small databases as an alternative for classic RDS

## Example of a minimally set pipeline:
```hcl
module "aurora" {
  source = "./modules/aurora"

  cluster_identifier = "app-aurora"
  engine             = "aurora-mysql"
  engine_version     = "8.0.mysql_aurora.3.08.0"

  database_name   = "appdb"
  master_username = "admin"
  master_password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.db.id]

  iam_database_authentication_enabled = true

  instances = {
    writer = {
      identifier     = "app-aurora-1"
      instance_class = "db.r6g.large"
      promotion_tier = 0
    }

    reader = {
      identifier     = "app-aurora-2"
      instance_class = "db.r6g.large"
      promotion_tier = 1
    }
  }

  tags = {
    App = "example"
  }
}
```

[Click here to view a folder of example tests](../../tests/code-pipeline)

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.6 |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.6 |

## Inputs

| Name | Description | Default | Required |
|------|-------------|---------|:--------:|
| <a name="input_apply_immediately"></a> [apply\_immediately](#input\_apply\_immediately) | n/a | `true` | no |
| <a name="input_backup_retention_period"></a> [backup\_retention\_period](#input\_backup\_retention\_period) | n/a | `1` | no |
| <a name="input_cluster_identifier"></a> [cluster\_identifier](#input\_cluster\_identifier) | n/a | `"aurora-test"` | no |
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | n/a | `"testdb"` | no |
| <a name="input_db_subnet_group_name"></a> [db\_subnet\_group\_name](#input\_db\_subnet\_group\_name) | n/a | `""` | no |
| <a name="input_engine"></a> [engine](#input\_engine) | n/a | `"aurora-postgresql"` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | n/a | `"15.2"` | no |
| <a name="input_final_snapshot_seed"></a> [final\_snapshot\_seed](#input\_final\_snapshot\_seed) | n/a | `""` | no |
| <a name="input_iam_database_authentication_enabled"></a> [iam\_database\_authentication\_enabled](#input\_iam\_database\_authentication\_enabled) | n/a | `false` | no |
| <a name="input_instances"></a> [instances](#input\_instances) | n/a | <pre>{<br/>  "test": {<br/>    "availability_zone": "us-east-1a",<br/>    "identifier": "aurora-test-instance",<br/>    "instance_class": "db.t3.micro",<br/>    "promotion_tier": 1,<br/>    "publicly_accessible": false,<br/>    "tags": {}<br/>  }<br/>}</pre> | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | n/a | `""` | no |
| <a name="input_master_password"></a> [master\_password](#input\_master\_password) | n/a | `"Password123!"` | no |
| <a name="input_master_username"></a> [master\_username](#input\_master\_username) | n/a | `"admin"` | no |
| <a name="input_port"></a> [port](#input\_port) | n/a | `5432` | no |
| <a name="input_preferred_backup_window"></a> [preferred\_backup\_window](#input\_preferred\_backup\_window) | n/a | `"02:00-03:00"` | no |
| <a name="input_storage_encrypted"></a> [storage\_encrypted](#input\_storage\_encrypted) | n/a | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | <pre>{<br/>  "Environment": "test"<br/>}</pre> | no |
| <a name="input_vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#input\_vpc\_security\_group\_ids) | n/a | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | n/a |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | n/a |
| <a name="output_final_snapshot_identifier"></a> [final\_snapshot\_identifier](#output\_final\_snapshot\_identifier) | n/a |
| <a name="output_reader_endpoint"></a> [reader\_endpoint](#output\_reader\_endpoint) | n/a |  
<!-- END_TF_DOCS -->