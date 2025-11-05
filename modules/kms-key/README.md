<!-- BEGIN_TF_DOCS -->


## Example

Halp

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Requirements

No requirements.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alias"></a> [alias](#input\_alias) | Alias to assign to the key if there is one | `string` | `null` | no |
| <a name="input_deletion_window_in_days"></a> [deletion\_window\_in\_days](#input\_deletion\_window\_in\_days) | Deletion windon in day. Defaults to 7 | `number` | `7` | no |
| <a name="input_description"></a> [description](#input\_description) | Description for the KMS key | `string` | n/a | yes |
| <a name="input_enable_whole_account_access"></a> [enable\_whole\_account\_access](#input\_enable\_whole\_account\_access) | Enable the whole account to be allowed to be given permissions to the key. Disable if absolutely necessary | `bool` | `true` | no |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | Is the key currently enabled | `bool` | `true` | no |
| <a name="input_key_usage"></a> [key\_usage](#input\_key\_usage) | Key Usage field to set on the key. Defaults to ENCRYPT\_DECRYPT | `string` | `"ENCRYPT_DECRYPT"` | no |
| <a name="input_permissions"></a> [permissions](#input\_permissions) | JSON policy to incorporate and possible override the 'Default' Sid policy statement with | `string` | `null` | no |
| <a name="input_rotation_period"></a> [rotation\_period](#input\_rotation\_period) | Rotation period to set on the key if there is one | `number` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Default tags to apply to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alias_arn"></a> [alias\_arn](#output\_alias\_arn) | n/a |
| <a name="output_key_arn"></a> [key\_arn](#output\_key\_arn) | n/a |
| <a name="output_key_id"></a> [key\_id](#output\_key\_id) | n/a |  
<!-- END_TF_DOCS -->