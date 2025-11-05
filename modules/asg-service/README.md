<!-- BEGIN_TF_DOCS -->
# AutoScaling Group Service

An EC2 autoscaling group based service to function similarly to an ECS service

The intent here is to help run systems at a larger scale that makes sense for fargate
or the services themselfves are too large for fargate. Alternatively, EC2 native
autoscaling policies are at the time of writing more configurable than ECS

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Requirements

No requirements.

## Inputs

| Name | Description | Default | Required |
|------|-------------|---------|:--------:|
| <a name="input_ami"></a> [ami](#input\_ami) | AMI to deploy to the group | n/a | yes |
| <a name="input_block_mappings"></a> [block\_mappings](#input\_block\_mappings) | Block mappings to attach to each server in the asg | <pre>[<br/>  {<br/>    "name": "/dev/sdf",<br/>    "size": 20<br/>  }<br/>]</pre> | no |
| <a name="input_capacity"></a> [capacity](#input\_capacity) | Capacity config for the group | `{}` | no |
| <a name="input_config"></a> [config](#input\_config) | Main ASG config | `{}` | no |
| <a name="input_ebs_optimized"></a> [ebs\_optimized](#input\_ebs\_optimized) | To enable the ASG to be ebs optimized | `true` | no |
| <a name="input_env_vars"></a> [env\_vars](#input\_env\_vars) | Environment variables to pass to the container in {<key> = <value>, <key> = <value>} form | `{}` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Instance type to deploy | n/a | yes |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | SSH key to attach to the instances | `null` | no |
| <a name="input_lb"></a> [lb](#input\_lb) | n/a | n/a | yes |
| <a name="input_log_retention"></a> [log\_retention](#input\_log\_retention) | Number of days to store the service logs for | `7` | no |
| <a name="input_managed_policies"></a> [managed\_policies](#input\_managed\_policies) | List of managed policies to attach to the group | `[]` | no |
| <a name="input_metadata"></a> [metadata](#input\_metadata) | Metadata properties to attach to the instances | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | Name for the autoscaling group and associated resources | n/a | yes |
| <a name="input_network"></a> [network](#input\_network) | Network config for the ASG | n/a | yes |
| <a name="input_permissions"></a> [permissions](#input\_permissions) | Json encoded string of permissions to attach to the container | `null` | no |
| <a name="input_protections"></a> [protections](#input\_protections) | Protection config | `{}` | no |
| <a name="input_public"></a> [public](#input\_public) | associate a public ip to the instances | `false` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | List of secrets to attach to the service | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to apply to all resources | `{}` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | User data needed to run the script | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cname_target"></a> [cname\_target](#output\_cname\_target) | DNS CNAME target to use to reach the service |  
<!-- END_TF_DOCS -->