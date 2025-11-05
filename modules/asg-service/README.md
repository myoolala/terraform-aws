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
| <a name="input_ami"></a> [ami](#input\_ami) | AMI to deploy to the group | `string` | n/a | yes |
| <a name="input_block_mappings"></a> [block\_mappings](#input\_block\_mappings) | Block mappings to attach to each server in the asg | <pre>list(object({<br/>    name                  = string<br/>    size                  = number<br/>    delete_on_termination = optional(bool, true)<br/>    encrypted             = optional(bool, true)<br/>    iops                  = optional(string, null)<br/>    kms_key               = optional(string, null)<br/>    snapshot_id           = optional(string, null)<br/>    type                  = optional(string, null)<br/>  }))</pre> | <pre>[<br/>  {<br/>    "name": "/dev/sdf",<br/>    "size": 20<br/>  }<br/>]</pre> | no |
| <a name="input_capacity"></a> [capacity](#input\_capacity) | Capacity config for the group | <pre>object({<br/>    initial               = optional(number, 1)<br/>    max                   = optional(number, 2)<br/>    min                   = optional(number, 1)<br/>    max_instance_lifetime = optional(number, null)<br/>  })</pre> | `{}` | no |
| <a name="input_config"></a> [config](#input\_config) | Main ASG config | <pre>object({<br/>    health_check_type       = optional(string, "ELB")<br/>    grace_period            = optional(number, 300)<br/>    service_linked_role_arn = optional(string, null)<br/>    termination_policies    = optional(list(string), [])<br/>    suspended_processes     = optional(list(string), [])<br/>  })</pre> | `{}` | no |
| <a name="input_ebs_optimized"></a> [ebs\_optimized](#input\_ebs\_optimized) | To enable the ASG to be ebs optimized | `bool` | `true` | no |
| <a name="input_env_vars"></a> [env\_vars](#input\_env\_vars) | Environment variables to pass to the container in {<key> = <value>, <key> = <value>} form | `map(string)` | `{}` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Instance type to deploy | `string` | n/a | yes |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | SSH key to attach to the instances | `string` | `null` | no |
| <a name="input_lb"></a> [lb](#input\_lb) | n/a | <pre>object({<br/>    vpc_id        = optional(string, null)<br/>    subnets       = optional(list(string), null)<br/>    ingress_cidrs = optional(list(string), ["0.0.0.0/0"])<br/>    # ingress_groups <br/>    egress_cidrs = optional(list(string), ["0.0.0.0/0"])<br/>    # egress_groups<br/>    type                = optional(string, "application")<br/>    internal            = optional(bool, false)<br/>    deletion_protection = optional(bool, false)<br/>    port_mappings = list(object({<br/>      listen_port  = number<br/>      sg_protocol  = optional(string, "tcp")<br/>      lb_protocol  = optional(string, "HTTPS")<br/>      forward_port = number<br/>      tg_protocol  = optional(string, "HTTPS")<br/>      cert         = optional(string, null)<br/>      target_type  = optional(string, "ip")<br/>      health_check = optional(object({<br/>        enabled             = optional(bool, true)<br/>        matcher             = optional(string, "200-499")<br/>        interval            = optional(number, 30)<br/>        healthy_threshold   = optional(number, 2)<br/>        unhealthy_threshold = optional(number, 4)<br/>        service_protocol    = optional(string, "HTTPS")<br/>        path                = optional(string, "/")<br/>      }), {})<br/>    }))<br/>  })</pre> | n/a | yes |
| <a name="input_log_retention"></a> [log\_retention](#input\_log\_retention) | Number of days to store the service logs for | `number` | `7` | no |
| <a name="input_managed_policies"></a> [managed\_policies](#input\_managed\_policies) | List of managed policies to attach to the group | `list(string)` | `[]` | no |
| <a name="input_metadata"></a> [metadata](#input\_metadata) | Metadata properties to attach to the instances | <pre>object({<br/>    enabled   = optional(string, "enabled")<br/>    tokens    = optional(string, "optional")<br/>    hop_limit = optional(number, 1)<br/>    tags      = optional(string, "enabled")<br/>  })</pre> | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | Name for the autoscaling group and associated resources | `string` | n/a | yes |
| <a name="input_network"></a> [network](#input\_network) | Network config for the ASG | <pre>object({<br/>    vpc            = string<br/>    subnets        = list(string)<br/>    additional_sgs = optional(list(string), [])<br/>    ingresses = optional(list(object({<br/>      from_port   = number<br/>      to_port     = number<br/>      protocol    = string<br/>      source_sg   = optional(string, null)<br/>      cidr_blocks = optional(list(string), null)<br/>    })), [])<br/>  })</pre> | n/a | yes |
| <a name="input_permissions"></a> [permissions](#input\_permissions) | Json encoded string of permissions to attach to the container | `string` | `null` | no |
| <a name="input_protections"></a> [protections](#input\_protections) | Protection config | <pre>object({<br/>    scale_in_protection    = optional(bool, false)<br/>    termination_protection = optional(bool, false)<br/>    stop_protection        = optional(bool, false)<br/>  })</pre> | `{}` | no |
| <a name="input_public"></a> [public](#input\_public) | associate a public ip to the instances | `bool` | `false` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | List of secrets to attach to the service | <pre>object({<br/>    secrets = list(map(string))<br/>    region  = string<br/>  })</pre> | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | User data needed to run the script | <pre>object({<br/>    pre_env  = optional(string, "")<br/>    post_env = optional(string, "")<br/>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cname_target"></a> [cname\_target](#output\_cname\_target) | n/a |  
<!-- END_TF_DOCS -->