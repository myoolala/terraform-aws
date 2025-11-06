<!-- BEGIN_TF_DOCS -->
# SNS

Creates an SNS topic with an optional KMS key configuration and policy configuration

[Examples can be found here](../../tests/sns/)

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Requirements

No requirements.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_display_name"></a> [display\_name](#input\_display\_name) | Display name to attach to the SNS Topic | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name to attach to the SNS Topic | `string` | n/a | yes |
| <a name="input_kms"></a> [kms](#input\_kms) | Encryption configuration which defaults to no encyrption. Supports passing in a key or creating one with the Key 'create' | <pre>object({<br/>    key             = string<br/>    deletion_window = optional(number, 14)<br/>    permissions = optional(string, "")<br/>  })</pre> | <pre>{<br/>  "key": null<br/>}</pre> | no |
| <a name="input_policy"></a> [policy](#input\_policy) | Policy to attach to the topic if applicable | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kms_key"></a> [kms\_key](#output\_kms\_key) | KMS key id that was provided or created |
| <a name="output_kms_key_alias_arn"></a> [kms\_key\_alias\_arn](#output\_kms\_key\_alias\_arn) | KMS key Alias ARN that was created |
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | KMS key ARN that was created |
| <a name="output_sns_arn"></a> [sns\_arn](#output\_sns\_arn) | ARN for the SNS topic |  
<!-- END_TF_DOCS -->