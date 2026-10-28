<!-- BEGIN_TF_DOCS -->
# ACM Certificate

Creates an ACM cert to be used by other resources

If provided, it will also automate the DNS verification for the certification

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
| <a name="output_arn"></a> [arn](#output\_arn) | ARN of the acm certificate if there is one that can be returned |  
<!-- END_TF_DOCS -->