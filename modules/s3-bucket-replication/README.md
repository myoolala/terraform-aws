# s3-bucket-replication

This module creates a backup S3 bucket in a secondary provider and configures replication from a source bucket in the primary provider. Replication can be one‑way (primary → backup) or two‑way (bi‑directional).

## Usage

```hcl
module "replication" {
  source = "../../../modules/s3-bucket-replication"

  source_bucket_name = "my-source-bucket"
  # optional backup bucket name
  # backup_bucket_name = "my-backup-bucket"
  replication_mode   = "two-way" # or "one-way"
}
```

## Inputs

- `source_bucket_name` - Name of the existing source bucket.
- `backup_bucket_name` - Optional. Name of the backup bucket. Defaults to `<source>-backup`.
- `replication_mode` - `one-way` (default) or `two-way`.
- `enable_versioning` - Enable versioning on backup bucket.
- `public_access_block` - Public access block configuration for the backup bucket.

## Outputs

- `backup_bucket_id`
- `backup_bucket_arn`
- `replication_role_arn`

<!-- BEGIN_TF_DOCS -->
# S3 Bucket Replication

Creates an S3 bucket replication configuration between a source bucket and a backup bucket in a second AWS account, optionally enabling two‑way replication and versioning.

This module uses two distinct AWS provider aliases `primary` and `backup` to target the different accounts.

## Example of a one‑way replication setup:
```hcl
module "source" {
  source = "../../../modules/s3-bucket"
  name   = "tf-test-bucket-123"
}

module "replication" {
  source             = "../../../modules/s3-bucket-replication"
  source_bucket_name = module.source.id
  replication_mode   = "one-way"
}
```

[More examples can be found here](../../tests/s3-bucket-replication/)

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws.backup"></a> [aws.backup](#provider\_aws.backup) | >= 6.66.0 |
| <a name="provider_aws.primary"></a> [aws.primary](#provider\_aws.primary) | >= 6.66.0 |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.66.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_source_bucket_name"></a> [source\_bucket\_name](#input\_source\_bucket\_name) | Name of the existing source bucket to replicate from | `string` | n/a | yes |
| <a name="input_backup_bucket_name"></a> [backup\_bucket\_name](#input\_backup\_bucket\_name) | Name of the backup bucket to create. Defaults to <source>-backup if omitted. | `string` | `""` | no |
| <a name="input_enable_versioning"></a> [enable\_versioning](#input\_enable\_versioning) | Enable versioning on the backup bucket | `bool` | `true` | no |
| <a name="input_public_access_block"></a> [public\_access\_block](#input\_public\_access\_block) | Public access block config for the backup bucket | <pre>object({<br/>    block_public_acls       = optional(bool, true)<br/>    block_public_policy     = optional(bool, true)<br/>    ignore_public_acls      = optional(bool, true)<br/>    restrict_public_buckets = optional(bool, true)<br/>  })</pre> | `{}` | no |
| <a name="input_replication_mode"></a> [replication\_mode](#input\_replication\_mode) | Replication direction: 'one-way' or 'two-way' | `string` | `"one-way"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_backup_bucket_arn"></a> [backup\_bucket\_arn](#output\_backup\_bucket\_arn) | The ARN of the backup bucket |
| <a name="output_backup_bucket_id"></a> [backup\_bucket\_id](#output\_backup\_bucket\_id) | The name of the backup bucket |
| <a name="output_replication_role_arn"></a> [replication\_role\_arn](#output\_replication\_role\_arn) | ARN of the replication role on the primary account |
<!-- END_TF_DOCS -->