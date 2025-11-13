<!-- BEGIN_TF_DOCS -->
# Rotate Admin Password function

Automates creating a lambda function that will use the AWS SDK to update the admin password to a passed in RDS instance or cluster

You have the option of passing all information to hook up EventBridge schedules to it all in one, or do it yourself if there are multiple databases

# Examples

## Base lambda with minimal configuration to a single rds instance

```hcl
locals {
  db_arn = "arn:aws:rds:us-east-1:123456789012:db:my-db-instance"
  db_identifier = "my-db-instance"
  secret_arn = "arn:aws:secretsmanager:us-east-1:123456789012:secret:db-admin-connection-info-abcdef"
}

data "aws_iam_policy_document" "rds_pw_updates" {
  statement {
    sid = "dbAccess"
    effect = "Allow"
    actions = [
      "rds:DescribeDbInstance",
      "rds:DescribeDbCluster",
      "rds:ModifyDbInstance",
      "rds:ModifyDbCluster",
    ]
    resources = [ local.db_arn ]
  }
  statement {
    sid = "secretAccess"
    effect = "Allow"
    actions = [
      "secretsmanager:PutSecretValue"
    ]
    resources = [ local.secret_arn ]
  }
}

module "test" {
  source = "../../../modules/rotate-admin-rds-pw"

  name = "test-integration-rotate-rds-pw"
  permissions = data.aws_iam_policy_document.rds_pw_updates.json
  event_schedule_input = {
    rdsIdentifier = local.db_identifier
    rdsAdminInfoLocation = local.secret_arn
  }

}
```

## Base lambda with minimal configuration to support manual invocation for multiple invocations

```hcl
module "test" {
  source = "../../../modules/rotate-admin-rds-pw"

  name = "test-integration-rotate-rds-pw"
  permissions = null
  schedule = null
  event_schedule_input = null
}
```

[More examples can be found here](../../tests/rotate-admin-rds-pw)

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | n/a |

## Requirements

No requirements.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_event_schedule_input"></a> [event\_schedule\_input](#input\_event\_schedule\_input) | Information to pass to the lambda when invoked to rotate the password | <pre>object({<br/>        rdsIdentifier = string<br/>        rdsAdminInfoLocation = string<br/>        mode = optional(string, "instance")<br/>        pwLength = optional(number, 64)<br/>    })</pre> | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | value | `string` | n/a | yes |
| <a name="input_permissions"></a> [permissions](#input\_permissions) | JSON encoded permissions string for any required DB/Secrets access | `string` | n/a | yes |
| <a name="input_alerts_topic"></a> [alerts\_topic](#input\_alerts\_topic) | Alert topic to send updates to if there is one | `string` | `null` | no |
| <a name="input_dy_run"></a> [dy\_run](#input\_dy\_run) | Is the lambda in dry run mode | `bool` | `false` | no |
| <a name="input_log_level"></a> [log\_level](#input\_log\_level) | Log level for the lambda function | `string` | `"INFO"` | no |
| <a name="input_schedule"></a> [schedule](#input\_schedule) | Schedule expression to trigger the lambda with if there is one. Make null if this gets shared with multiple databases | `string` | `"rate(30 days)"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_function_arn"></a> [function\_arn](#output\_function\_arn) | ARN of the Lambda function created |
| <a name="output_function_name"></a> [function\_name](#output\_function\_name) | Name of the Lambda function created |
| <a name="output_invoke_arn"></a> [invoke\_arn](#output\_invoke\_arn) | Invoke ARN of the Lambda to connect with EventBridge |
| <a name="output_role"></a> [role](#output\_role) | Role assigned to the Lambda function to add permissions to |  
<!-- END_TF_DOCS -->