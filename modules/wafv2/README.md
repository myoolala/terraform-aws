<!-- BEGIN_TF_DOCS -->
# WAFv2 Module

Deploys an AWS WAFv2 Web ACL with optional managed rule groups and custom IP sets, and associates it with an Application Load Balancer when an ALB ARN is provided.

[Examples can be found here](../../tests/wafv2)

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.25.0 |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.25.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_default_action"></a> [default\_action](#input\_default\_action) | The default action for the Web ACL. Must be one of ALLOW or BLOCK. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name used to identify the WAF Web ACL and associated resources. | `string` | n/a | yes |
| <a name="input_alb_arn"></a> [alb\_arn](#input\_alb\_arn) | ARN of the ALB to associate this Web ACL with. Optional. | `string` | `null` | no |
| <a name="input_ip_sets"></a> [ip\_sets](#input\_ip\_sets) | Custom IP allow or block lists. Each item must contain name, addresses, and action. | <pre>list(object({<br/>    name      = string<br/>    addresses = list(string)<br/>    action    = string<br/>  }))</pre> | `[]` | no |
| <a name="input_managed_rule_groups"></a> [managed\_rule\_groups](#input\_managed\_rule\_groups) | List of AWS managed rule groups to include. Each item must contain name and vendor. | <pre>list(object({<br/>    name           = string<br/>    vendor         = string<br/>    excluded_rules = optional(list(string), [])<br/>  }))</pre> | `[]` | no |
| <a name="input_scope"></a> [scope](#input\_scope) | The scope of the Web ACL. Defaults to REGIONAL. | `string` | `"REGIONAL"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags to apply to resources created by this module. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_association_arn"></a> [association\_arn](#output\_association\_arn) | The ARN of the Web ACL association with the ALB, if created. |
| <a name="output_web_acl_arn"></a> [web\_acl\_arn](#output\_web\_acl\_arn) | The ARN of the created Web ACL. |
| <a name="output_web_acl_id"></a> [web\_acl\_id](#output\_web\_acl\_id) | The ID of the created Web ACL. |
<!-- END_TF_DOCS -->