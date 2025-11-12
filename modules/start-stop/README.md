<!-- BEGIN_TF_DOCS -->
# Start Stop Lambda Service

Creates a lambda that scans ASG's, ECS services, EC2 instances, and EventBridge rules for anything that can be enabled/disabled via a schedule. This is done via tags to all for a single regional deployment of this lambda to affect any number of services.

The default permissions are expansive and should be restricted down as necessary per system.

It runs on a default schedule of every 30 minutes

The tag it looks for is configurable enabling multiple deployments of this lambda for multiple projects even without permissions

For the services:

- ASG is scaled to the minimum size or the minimum size + 1
- EC2 instance is stopped/started
- ECS Service is scaled to 0 or 1 tasks
- EventBridge rules are enabled/disabled

# Examples

## Basic minimally set service

```hcl
module "start_stop_lambder" {
  source = "../../../modules/start-stop"

  name = "start-stop-service"
}
```

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Requirements

No requirements.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Name to give the start/stop Lambda | `string` | n/a | yes |
| <a name="input_dry_run_mode_enabled"></a> [dry\_run\_mode\_enabled](#input\_dry\_run\_mode\_enabled) | Is dry run mode enabled in the Lambda or not | `bool` | `false` | no |
| <a name="input_log_level"></a> [log\_level](#input\_log\_level) | Log level for the lambda. Default is INFO | `string` | `"INFO"` | no |
| <a name="input_log_retention"></a> [log\_retention](#input\_log\_retention) | Log retention in days for the Lambda | `number` | `7` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Default memory allocation for the runtime | `number` | `128` | no |
| <a name="input_permissions"></a> [permissions](#input\_permissions) | JSON encoded permissions policy to override the default policy with | `string` | `null` | no |
| <a name="input_schedule"></a> [schedule](#input\_schedule) | Schedule to run the start/stop Lambda on | `string` | `"cron(*/30 * * * ? *)"` | no |
| <a name="input_sns_alert_topics"></a> [sns\_alert\_topics](#input\_sns\_alert\_topics) | List of SNS topic ARN's to send errors to | `list(string)` | `[]` | no |
| <a name="input_start_grace_period"></a> [start\_grace\_period](#input\_start\_grace\_period) | Number of hours to allow premature starting of the instance | `number` | `0` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Timeout for the Lambda function | `number` | `60` | no |

## Outputs

No outputs.  
<!-- END_TF_DOCS -->