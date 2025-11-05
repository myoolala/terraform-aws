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
| <a name="input_domain"></a> [domain](#input\_domain) | Domain(s) for the cert to be attached to | `string` | `null` | no |
| <a name="input_hosted_zone"></a> [hosted\_zone](#input\_hosted\_zone) | Hosted zone to use for DNS verification, if applicable | `string` | `null` | no |
| <a name="input_private"></a> [private](#input\_private) | Is the hosted zone public if appplicable | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | n/a |  
<!-- END_TF_DOCS -->