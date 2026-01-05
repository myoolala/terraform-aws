<!-- BEGIN_TF_DOCS -->
# Scheduled Task

Creates a scheduled task job that runs on a cron. The intended purpose is to allow serverless crons to run that are too big for Lambda.

And example use case would be a database backup to s3 for something greater than 10GB. Or an analytic job that runs for more than 15 minutes

This also automates creating everything needed to run the job, much like the fargate service, such that it takes minimal effort to run for a Lambda based application

[Example implementation](../../tests/scheduled-job)

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Requirements

No requirements.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster"></a> [cluster](#input\_cluster) | Cluster configuration to attach to the scheduled task | <pre>object({<br/>    create = optional(bool, true)<br/>    name   = optional(string, null)<br/>    arn    = optional(string, null)<br/>  })</pre> | n/a | yes |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | Name to apply to the Fargate service | `string` | n/a | yes |
| <a name="input_service_subnets"></a> [service\_subnets](#input\_service\_subnets) | Subnets to run the service in | `list(string)` | n/a | yes |
| <a name="input_trigger"></a> [trigger](#input\_trigger) | Trigger for a scheduled task | <pre>object({<br/>    schedule_expression = optional(string, null)<br/>    event_pattern = optional(string, null)<br/>  })</pre> | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC to run the service in | `string` | n/a | yes |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | CPU value to give to the docker definition | `number` | `256` | no |
| <a name="input_create_ecr_repo"></a> [create\_ecr\_repo](#input\_create\_ecr\_repo) | Create a new ecr repo or not | `bool` | `true` | no |
| <a name="input_encrypt_logs"></a> [encrypt\_logs](#input\_encrypt\_logs) | Do you want the cloudwatch logs encrypted | <pre>object({<br/>    enabled      = bool<br/>    existing_key = optional(string, null)<br/>  })</pre> | <pre>{<br/>  "enabled": false<br/>}</pre> | no |
| <a name="input_env_vars"></a> [env\_vars](#input\_env\_vars) | Environment variables to pass to the container in {<key> = <value>, <key> = <value>} form | `map(string)` | `{}` | no |
| <a name="input_image_tag"></a> [image\_tag](#input\_image\_tag) | Version of the app in ECR to deploy | `string` | `null` | no |
| <a name="input_input"></a> [input](#input\_input) | Input overrides to attach to the task if there are any | `string` | `null` | no |
| <a name="input_log_retention"></a> [log\_retention](#input\_log\_retention) | Number of days to store the service logs for | `number` | `7` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Memory amount in MB to give to the docker definition | `number` | `512` | no |
| <a name="input_permissions"></a> [permissions](#input\_permissions) | Json encoded string of permissions to attach to the container | `string` | `null` | no |
| <a name="input_public"></a> [public](#input\_public) | Should the docker containers get assigned public ip's | `string` | `false` | no |
| <a name="input_scan_on_push"></a> [scan\_on\_push](#input\_scan\_on\_push) | Have ECR scan images on push | `bool` | `true` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | List of secrets to attach to the service | <pre>list(object({<br/>    name     = optional(string)<br/>    value    = string<br/>    env_name = string<br/>    create   = optional(bool, false)<br/>  }))</pre> | `[]` | no |
| <a name="input_storage"></a> [storage](#input\_storage) | Amount of storage, in GB, to allocate to the container | `number` | `21` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources. Ie: environment, cost tracking, etc... | `map(any)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | ARN for the ECS cluster |
| <a name="output_container_sg"></a> [container\_sg](#output\_container\_sg) | Security Group for the container |
| <a name="output_ecr_arn"></a> [ecr\_arn](#output\_ecr\_arn) | ARN for the ECR Repo if one was created |
| <a name="output_ecr_repo"></a> [ecr\_repo](#output\_ecr\_repo) | Repository URL for the ECR Repo if one was created |  
<!-- END_TF_DOCS -->