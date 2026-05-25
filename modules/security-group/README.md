<!-- BEGIN_TF_DOCS -->
# Security Group

Thin wrapper around a security group to allow inline specification of ingress/egree rules without causing the normal issues

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Requirements

No requirements.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Name for the security group | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC to house the SG | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | Description for the new security group | `string` | `""` | no |
| <a name="input_egresses"></a> [egresses](#input\_egresses) | List of egress rules to attach in an inline method without ruining everyone's day | <pre>list(object({<br/>    from_port                = number<br/>    to_port                  = number<br/>    description              = optional(string, "Managed by terraform")<br/>    protocol                 = string<br/>    source_security_group_id = optional(string, null)<br/>    cidr_blocks              = optional(list(string), null)<br/>  }))</pre> | <pre>[<br/>  {<br/>    "cidr_blocks": [<br/>      "0.0.0.0/0"<br/>    ],<br/>    "from_port": 0,<br/>    "protocol": "-1",<br/>    "to_port": 0<br/>  }<br/>]</pre> | no |
| <a name="input_ingresses"></a> [ingresses](#input\_ingresses) | List of ingress rules to attach in an inline method without ruining everyone's day | <pre>list(object({<br/>    from_port                = number<br/>    to_port                  = number<br/>    description              = optional(string, "Managed by terraform")<br/>    protocol                 = string<br/>    source_security_group_id = optional(string, null)<br/>    cidr_blocks              = optional(list(string), null)<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | ID of the Security Group |  
<!-- END_TF_DOCS -->