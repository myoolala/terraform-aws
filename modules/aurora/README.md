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

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | n/a |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | n/a |
| <a name="output_final_snapshot_identifier"></a> [final\_snapshot\_identifier](#output\_final\_snapshot\_identifier) | n/a |
| <a name="output_reader_endpoint"></a> [reader\_endpoint](#output\_reader\_endpoint) | n/a |  
<!-- END_TF_DOCS -->