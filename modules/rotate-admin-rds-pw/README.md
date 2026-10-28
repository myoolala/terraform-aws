<!-- BEGIN_TF_DOCS -->
# Rotate Admin RDS Password

Deploys a Lambda function that rotates the admin password for an RDS instance or cluster.

The Lambda has an optional schedule, optional VPC placement, and can send alerts to an SNS topic.

## Example of rotating an instance password on a schedule:
```hcl
module "rotate_pw" {
  source            = "../../../modules/rotate-admin-rds-pw"
  name              = "tf-rds-rotator"
  schedule          = "rate(30 days)"
  event_schedule_input = {
    rdsIdentifier        = "my-db-instance"
    rdsAdminInfoLocation = "s3://bucket/key.json"
  }
}
```

[More examples can be found here](../../tests/rotate-admin-rds-pw/)

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | n/a |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0 |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_event_schedule_input"></a> [event\_schedule\_input](#input\_event\_schedule\_input) | Event payload passed to the Lambda at runtime. | <pre>object({<br/>    rdsIdentifier        = string<br/>    rdsAdminInfoLocation = string<br/>    mode                 = optional(string, "instance")<br/>    pwLength             = optional(number, 64)<br/>  })</pre> | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the Lambda function to create. | `string` | n/a | yes |
| <a name="input_permissions"></a> [permissions](#input\_permissions) | Additional IAM policy permissions for the lambda role. Must be JSON encoded array of policy statements. | `any` | n/a | yes |
| <a name="input_alerts_topic"></a> [alerts\_topic](#input\_alerts\_topic) | ARN of an SNS topic to send alerts to. | `string` | `null` | no |
| <a name="input_dy_run"></a> [dy\_run](#input\_dy\_run) | Toggle dry run mode. | `bool` | `false` | no |
| <a name="input_existing_code"></a> [existing\_code](#input\_existing\_code) | If set, use an existing Lambda layer ARN or a path to a zip file. | `string` | `null` | no |
| <a name="input_log_level"></a> [log\_level](#input\_log\_level) | Logging level. | `string` | `"INFO"` | no |
| <a name="input_schedule"></a> [schedule](#input\_schedule) | Optional cron or rate expression to schedule automatic invocation of the lambda function. | `string` | `"rate(30 days)"` | no |
| <a name="input_vpc_config"></a> [vpc\_config](#input\_vpc\_config) | VPC configuration for the Lambda. | <pre>object({<br/>    id              = string<br/>    subnets         = list(string)<br/>    security_groups = optional(list(string))<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_function_arn"></a> [function\_arn](#output\_function\_arn) | ARN of the Lambda function created |
| <a name="output_function_name"></a> [function\_name](#output\_function\_name) | Name of the Lambda function created |
| <a name="output_invoke_arn"></a> [invoke\_arn](#output\_invoke\_arn) | Invoke ARN of the Lambda to connect with EventBridge |
| <a name="output_role"></a> [role](#output\_role) | Role assigned to the Lambda function to add permissions to |
<!-- END_TF_DOCS -->