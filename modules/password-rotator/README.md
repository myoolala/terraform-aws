<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | 2.8.1 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.3.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_lambda"></a> [lambda](#module\_lambda) | ../lambda | n/a |

## Resources

| Name | Type |
|------|------|
| [archive_file.lambda_func](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/resources/file) | resource |
| [null_resource.install_node_modules](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_default_password_config"></a> [default\_password\_config](#input\_default\_password\_config) | JSON string providing default configuration for password rotation. | `string` | `null` | no |
| <a name="input_force_rotate_env_var"></a> [force\_rotate\_env\_var](#input\_force\_rotate\_env\_var) | Time in milliseconds to force rotate the Lambda environment. | `string` | `null` | no |
| <a name="input_lambda_function_name"></a> [lambda\_function\_name](#input\_lambda\_function\_name) | The name of the Lambda function to create. | `string` | n/a | yes |
| <a name="input_lambda_layer_arn"></a> [lambda\_layer\_arn](#input\_lambda\_layer\_arn) | Optional ARN of a Lambda layer to attach. | `string` | `null` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Memory allocation per runtime for the lambda function. | `number` | `128` | no |
| <a name="input_permissions"></a> [permissions](#input\_permissions) | Additional IAM policy permissions for the lambda role. Must be JSON encoded array of policy statements. | `any` | `null` | no |
| <a name="input_schedule"></a> [schedule](#input\_schedule) | Optional cron or rate expression to schedule automatic invocation of the lambda function. | `string` | `"rate(90 days)"` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | Secrets ARNs and associated KMS key ARNs the lambda will need access to | <pre>object({<br/>    arns     = list(string)<br/>    kms_keys = list(string)<br/>  })</pre> | <pre>{<br/>  "arns": [],<br/>  "kms_keys": []<br/>}</pre> | no |
| <a name="input_service_rotation"></a> [service\_rotation](#input\_service\_rotation) | Optionally force service rotation. Allowed values: fargate, asg, lambda. | `string` | `null` | no |
| <a name="input_vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#input\_vpc\_security\_group\_ids) | Optional list of security group IDs for VPC configuration. | `list(string)` | `[]` | no |
| <a name="input_vpc_subnet_ids"></a> [vpc\_subnet\_ids](#input\_vpc\_subnet\_ids) | Optional list of subnet IDs for VPC configuration. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lambda_function_invoke_arn"></a> [lambda\_function\_invoke\_arn](#output\_lambda\_function\_invoke\_arn) | Invoke ARN of the created Lambda function. |
| <a name="output_lambda_function_name"></a> [lambda\_function\_name](#output\_lambda\_function\_name) | Name of the created Lambda function. |
| <a name="output_lambda_log_group"></a> [lambda\_log\_group](#output\_lambda\_log\_group) | Log group configuration created for the Lambda function. |
| <a name="output_lambda_role_arn"></a> [lambda\_role\_arn](#output\_lambda\_role\_arn) | ARN of the IAM role used by the Lambda function. |
| <a name="output_lambda_role_name"></a> [lambda\_role\_name](#output\_lambda\_role\_name) | The name of the IAM role used by the Lambda function. |
| <a name="output_lambda_security_group_ids"></a> [lambda\_security\_group\_ids](#output\_lambda\_security\_group\_ids) | List of security group IDs attached to the Lambda function if any. |
<!-- END_TF_DOCS -->