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
| <a name="input_api_log_group"></a> [api\_log\_group](#input\_api\_log\_group) | Log group name of the place to send stage logs to if a gateway was provided | `string` | `null` | no |
| <a name="input_auto_deploy"></a> [auto\_deploy](#input\_auto\_deploy) | Whether updates to an API automatically trigger a new deployment | `bool` | `false` | no |
| <a name="input_bucket_key"></a> [bucket\_key](#input\_bucket\_key) | S3 URI for the lambda zip file | `string` | n/a | yes |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Name of the bucket the code will be stored in | `string` | n/a | yes |
| <a name="input_create_new_gateway"></a> [create\_new\_gateway](#input\_create\_new\_gateway) | Create a new gateway for the lambda to use | `bool` | `true` | no |
| <a name="input_endpoints"></a> [endpoints](#input\_endpoints) | List of endpoints to register to the lambda | `set(string)` | n/a | yes |
| <a name="input_environment_vars"></a> [environment\_vars](#input\_environment\_vars) | Environment variables to pass into the lambda | `map(string)` | `null` | no |
| <a name="input_gateway_arn"></a> [gateway\_arn](#input\_gateway\_arn) | ARN of an existing API gateway to use if you are not creating one | `string` | `null` | no |
| <a name="input_gateway_id"></a> [gateway\_id](#input\_gateway\_id) | Id of an existing API gateway to use if you are not creating one | `string` | `null` | no |
| <a name="input_lambda_name"></a> [lambda\_name](#input\_lambda\_name) | Name for the lambda function | `string` | n/a | yes |
| <a name="input_make_new_bucket"></a> [make\_new\_bucket](#input\_make\_new\_bucket) | Is a new bucket to store the code desired | `bool` | `false` | no |
| <a name="input_path_prefix"></a> [path\_prefix](#input\_path\_prefix) | Common path shared between all endpoints | `string` | n/a | yes |
| <a name="input_permissions"></a> [permissions](#input\_permissions) | Additional permissions the lambda will need | `map(any)` | `null` | no |
| <a name="input_protocol"></a> [protocol](#input\_protocol) | Protocol for the lambda api | `string` | `"HTTP"` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | List of secrets and associated kms keys the lambda will need access to | <pre>object({<br/>    arns     = list(string)<br/>    kms_keys = list(string)<br/>  })</pre> | <pre>{<br/>  "arns": [],<br/>  "kms_keys": []<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_function_name"></a> [function\_name](#output\_function\_name) | n/a |
| <a name="output_path_prefix"></a> [path\_prefix](#output\_path\_prefix) | n/a |
| <a name="output_routes"></a> [routes](#output\_routes) | n/a |
| <a name="output_stage_name"></a> [stage\_name](#output\_stage\_name) | n/a |  
<!-- END_TF_DOCS -->