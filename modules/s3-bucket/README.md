<!-- BEGIN_TF_DOCS -->
# S3 Bucket

Creates an S3 bucket with some automated behavior like setting encryption and versioning

[Examples can be found here](../../tests/s3-bucket)

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Requirements

No requirements.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Name for the bucket | `string` | n/a | yes |
| <a name="input_encryption"></a> [encryption](#input\_encryption) | Attach an encryption key to the bucket. Specify the key if you already have one, or use a different encryption option | <pre>object({<br/>    key                = optional(string, null)<br/>    algorithm          = string<br/>    blocked_encryption_types = optional(list(string), ["SSE-C"])<br/>    bucket_key_enabled = optional(bool, false)<br/>  })</pre> | <pre>{<br/>  "algorithm": "AES256",<br/>  "bucket_key_enabled": true,<br/>  "key": null<br/>}</pre> | no |
| <a name="input_public_access_block"></a> [public\_access\_block](#input\_public\_access\_block) | Public access block config for the bucket | <pre>object({<br/>    block_public_acls       = optional(bool, true)<br/>    block_public_policy     = optional(bool, true)<br/>    ignore_public_acls      = optional(bool, true)<br/>    restrict_public_buckets = optional(bool, true)<br/>  })</pre> | `{}` | no |
| <a name="input_versioning_enabled"></a> [versioning\_enabled](#input\_versioning\_enabled) | Is versioning enabled for the bucket | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The bucket ARN |
| <a name="output_id"></a> [id](#output\_id) | The bucket name |
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | The default encryption key for the bucket |
| <a name="output_versioning_id"></a> [versioning\_id](#output\_versioning\_id) | The version ID for the bucket |  
<!-- END_TF_DOCS -->