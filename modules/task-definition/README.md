<!-- BEGIN_TF_DOCS -->
# Task Definition

Creates a Task Definition for an ECS service/task. Automates the IAM provisioning and creating the Task Definition itself

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Requirements

No requirements.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_image"></a> [image](#input\_image) | Container image to attach to the task defition | `string` | n/a | yes |
| <a name="input_log_group"></a> [log\_group](#input\_log\_group) | Name of the cloudwatch group to store logs in | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name to assign to the new task definition | `string` | n/a | yes |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | Name of the service to associate the definition with | `string` | n/a | yes |
| <a name="input_command"></a> [command](#input\_command) | Command to pass to the container | `list(string)` | `null` | no |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | CPU value to give to the docker definition | `number` | `256` | no |
| <a name="input_enable_ssm_access"></a> [enable\_ssm\_access](#input\_enable\_ssm\_access) | Enable the container to be reached via the ssm service | `bool` | `false` | no |
| <a name="input_env_vars"></a> [env\_vars](#input\_env\_vars) | Environment variables to pass to the container in {<key> = <value>, <key> = <value>} form | `map(string)` | `{}` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Memory amount in MB to give to the docker definition | `number` | `512` | no |
| <a name="input_permissions"></a> [permissions](#input\_permissions) | Json encoded string of permissions to attach to the container | `string` | `null` | no |
| <a name="input_port_mappings"></a> [port\_mappings](#input\_port\_mappings) | n/a | `list(map(number))` | <pre>[<br/>  {<br/>    "containerPort": 443,<br/>    "hostPort": 443<br/>  }<br/>]</pre> | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | Secrets to load into the container's environment | <pre>list(object({<br/>    name      = string<br/>    valueFrom = string<br/>  }))</pre> | `[]` | no |
| <a name="input_secrets_keys"></a> [secrets\_keys](#input\_secrets\_keys) | If there are any kms keys used with the secrets, add them here | `list(string)` | `[]` | no |
| <a name="input_storage"></a> [storage](#input\_storage) | Size of the ephemeral storage volume for the container | `number` | `21` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources. Ie: environment, cost tracking, etc... | `map(any)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_task_definition_arn"></a> [task\_definition\_arn](#output\_task\_definition\_arn) | ARN of the new Task Definition |  
<!-- END_TF_DOCS -->