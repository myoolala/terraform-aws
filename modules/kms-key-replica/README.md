# KMS Key Replica Module

This module creates a replicated KMS key using `aws_kms_replica_key`. It allows optional permission policies, description, alias, and tags.

<!-- BEGIN_TF_DOCS -->
# KMS Key Replica

Creates a replica of an existing KMS key in another AWS account using `aws_kms_replica_key`.

Optionally assigns an alias to the replica and merges any supplied policy statements.

## Example of creating a replica with an alias:
```hcl
module "source" {
  source = "../../../modules/kms-key"
  name   = "tf-test-key"
}

module "replica" {
  source          = "../../../modules/kms-key-replica"
  source_key_arn  = module.source.arn
  replica_alias   = "alias/tf-test-key-replica"
  tags            = { "env" = "test" }
}
```

[More examples can be found here](../../tests/kms-key-replica/)

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.68.0 |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_source_key_arn"></a> [source\_key\_arn](#input\_source\_key\_arn) | ARN of the source key to replicate | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | Optional description for the replica key | `string` | `null` | no |
| <a name="input_permissions"></a> [permissions](#input\_permissions) | Optional JSON policy to incorporate into the replica key policy | `string` | `null` | no |
| <a name="input_replica_alias"></a> [replica\_alias](#input\_replica\_alias) | Alias to assign to the replica key, if desired | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the replica key | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_replica_alias_arn"></a> [replica\_alias\_arn](#output\_replica\_alias\_arn) | ARN of the alias for the replica key if created |
| <a name="output_replica_key_arn"></a> [replica\_key\_arn](#output\_replica\_key\_arn) | ARN of the replica KMS key |
| <a name="output_replica_key_id"></a> [replica\_key\_id](#output\_replica\_key\_id) | ID of the replica KMS key |
<!-- END_TF_DOCS -->