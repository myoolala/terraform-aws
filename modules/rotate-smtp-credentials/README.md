<!-- BEGIN_TF_DOCS -->
# rotate-smtp-credentials

This module rotates IAM user credentials used for SMTP access and stores the new credentials in either AWS SSM Parameter Store or AWS Secrets Manager. It uses the generic `credential-rotator` module for Lambda packaging and deployment.

## Example

```hcl
module "rotate_smtp" {
  source          = "github.com/myoolala/terraform-aws//modules/rotate-smtp-credentials"
  name            = "tf-smtp-rotator"
  iam_user        = "example-user"
  ssm_parameter   = "/smtp/credentials"
}
```

[More examples can be found here](../../tests/rotate-smtp-credentials/)

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | 2.8.1 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.69.0 |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_iam_user"></a> [iam\_user](#input\_iam\_user) | IAM username whose credentials will be rotated. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the Lambda function to create. | `string` | n/a | yes |
| <a name="input_additonal_environment_vars"></a> [additonal\_environment\_vars](#input\_additonal\_environment\_vars) | Environment variables to pass or override into the lambda | `map(string)` | `{}` | no |
| <a name="input_existing_code"></a> [existing\_code](#input\_existing\_code) | ARN of an existing Lambda layer or a path to a zip file to override the default hook layer. | `string` | `null` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Memory allocation per runtime for the lambda function. | `number` | `512` | no |
| <a name="input_permissions"></a> [permissions](#input\_permissions) | JSON encoded IAM policy statements to merge with the required permissions. | `any` | `null` | no |
| <a name="input_schedule"></a> [schedule](#input\_schedule) | Cron or rate expression to schedule automatic invocation of the Lambda. | `string` | `null` | no |
| <a name="input_secretsmanager_secret"></a> [secretsmanager\_secret](#input\_secretsmanager\_secret) | Secrets Manager secret ARN to store the credentials. Optional | `string` | `null` | no |
| <a name="input_sns_topic"></a> [sns\_topic](#input\_sns\_topic) | SNS topic ARN to publish error messages. Optional | `string` | `null` | no |
| <a name="input_ssm_parameter"></a> [ssm\_parameter](#input\_ssm\_parameter) | SSM Parameter Store paths to store the credentials. Optional | `string` | `null` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Max allowed run time for the lambda | `number` | `60` | no |
| <a name="input_vpc_config"></a> [vpc\_config](#input\_vpc\_config) | VPC configuration for the Lambda. | <pre>object({<br/>    id              = string<br/>    subnets         = list(string)<br/>    security_groups = optional(list(string))<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_function_arn"></a> [function\_arn](#output\_function\_arn) | ARN of the Lambda function created |
| <a name="output_function_name"></a> [function\_name](#output\_function\_name) | Name of the Lambda function created |
| <a name="output_invoke_arn"></a> [invoke\_arn](#output\_invoke\_arn) | Invoke ARN of the Lambda to connect with EventBridge |
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | Role assigned to the Lambda function to add permissions to |
| <a name="output_role_name"></a> [role\_name](#output\_role\_name) | Role assigned to the Lambda function to add permissions to |
<!-- END_TF_DOCS -->
