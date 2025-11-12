<!-- BEGIN_TF_DOCS -->
# Lambda function

Automates creating a lambda function, IAM role, CloudWatch logs, IAM permissions, and Security groups all in one module. The intention is to reduce the repeat work for a simple lambda.

If there is no code to deploy, like on an initial deploy of an environment, a default zip file is deployed in place to prevent the lambda from erroring out

# Examples

## Base lambda with minimal configuration

```hcl
module "lambda" {
  source = "../../../modules/lambda"

  function_name = "lambda-function"
  file_path     = archive_file.source.output_path
}
```

## Lambda with a cron based schedule to automatically trigger invocation

```hcl
module "lambda" {
  source = "../../../modules/lambda"

  function_name = "lambda-function"
  file_path     = archive_file.source.output_path
  schedule = "rate(1 day)"
}
```

[More examples can be found here](../../tests/lambda)

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | n/a |
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Requirements

No requirements.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_function_name"></a> [function\_name](#input\_function\_name) | Name for the new lambda function | `string` | n/a | yes |
| <a name="input_bucket"></a> [bucket](#input\_bucket) | Name of the bucket to pull the code from | `string` | `null` | no |
| <a name="input_environment_vars"></a> [environment\_vars](#input\_environment\_vars) | Environment variables to pass into the lambda | `map(string)` | `null` | no |
| <a name="input_file_path"></a> [file\_path](#input\_file\_path) | Path to the zip file to deploy if one is available | `string` | `null` | no |
| <a name="input_handler"></a> [handler](#input\_handler) | Handler function | `string` | `"index.handler"` | no |
| <a name="input_key"></a> [key](#input\_key) | S3 Key of the source zip file | `string` | `null` | no |
| <a name="input_log_retention"></a> [log\_retention](#input\_log\_retention) | Number in days to store logs in cloudwatch | `number` | `7` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Memory allocation per runtime for the lambda | `number` | `128` | no |
| <a name="input_permissions"></a> [permissions](#input\_permissions) | Additional permissions the lambda will need json encoded | `string` | `null` | no |
| <a name="input_role"></a> [role](#input\_role) | Existing role to attach to the lambda if desired | `string` | `null` | no |
| <a name="input_runtime"></a> [runtime](#input\_runtime) | Runtime to use for the lambda | `string` | `"nodejs22.x"` | no |
| <a name="input_schedule"></a> [schedule](#input\_schedule) | Cron schedule to invoke the lambda on if there is one | `string` | `null` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | List of secrets and associated kms keys the lambda will need access to | <pre>object({<br/>    arns     = list(string)<br/>    kms_keys = list(string)<br/>  })</pre> | <pre>{<br/>  "arns": [],<br/>  "kms_keys": []<br/>}</pre> | no |
| <a name="input_tg_arns"></a> [tg\_arns](#input\_tg\_arns) | List of target group ARN's to attach to the lamdba | `list(string)` | `[]` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Lambda timeout allowed | `number` | `3` | no |
| <a name="input_vpc_config"></a> [vpc\_config](#input\_vpc\_config) | VPC config for the lambda | <pre>object({<br/>    subnet_ids         = list(string)<br/>    security_group_ids = list(string)<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_function_arn"></a> [function\_arn](#output\_function\_arn) | ARN of the Lambda function |
| <a name="output_function_name"></a> [function\_name](#output\_function\_name) | Name applied to the Lambda function |
| <a name="output_invoke_arn"></a> [invoke\_arn](#output\_invoke\_arn) | The invoke ARN of the Lambda function |
| <a name="output_role"></a> [role](#output\_role) | ARN of the role created to add permissions to |  
<!-- END_TF_DOCS -->