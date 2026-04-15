<!-- BEGIN_TF_DOCS -->
# Fargate Service

Creates an ECS Fargate Service. Automates creating the:

- cluster if needed
- ECR repo if needed
- IAM roles if needed
- Cloudwatch logs
- Task definition
- Secrets if needed
- Load balancer
- And anything else needed to run a service in Fargate

Currently there are limitation with ENV vars done via SSM, or enabling autoscaling policies and EFS volumes.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Requirements

No requirements.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster"></a> [cluster](#input\_cluster) | Cluster information for the service | <pre>object({<br/>    create = optional(bool, false)<br/>    name   = optional(string, null)<br/>    arn    = optional(string, null)<br/>  })</pre> | n/a | yes |
| <a name="input_network"></a> [network](#input\_network) | Network config to attach to the service containers | <pre>object({<br/>    vpc_id  = string<br/>    subnets = optional(list(string), null)<br/>  })</pre> | n/a | yes |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | Name to apply to the Fargate service | `string` | n/a | yes |
| <a name="input_command"></a> [command](#input\_command) | Description to pass to the task definition | `list(string)` | `null` | no |
| <a name="input_default_egress"></a> [default\_egress](#input\_default\_egress) | Default egress rule for the created security group | <pre>object({<br/>    from_port   = number<br/>    to_port     = number<br/>    protocol    = string<br/>    cidr_blocks = list(string)<br/>  })</pre> | <pre>{<br/>  "cidr_blocks": [<br/>    "0.0.0.0/0"<br/>  ],<br/>  "from_port": 0,<br/>  "protocol": "-1",<br/>  "to_port": 0<br/>}</pre> | no |
| <a name="input_desired_count"></a> [desired\_count](#input\_desired\_count) | Initial desired count of containers for the service | `number` | `2` | no |
| <a name="input_ecr"></a> [ecr](#input\_ecr) | ECR configuration for the service | <pre>object({<br/>    create       = optional(bool, true)<br/>    scan_on_push = optional(bool, true)<br/>  })</pre> | <pre>{<br/>  "create": true,<br/>  "scan_on_push": true<br/>}</pre> | no |
| <a name="input_env_vars"></a> [env\_vars](#input\_env\_vars) | Environment variables to pass to the container in {<key> = <value>, <key> = <value>} form | `map(string)` | `{}` | no |
| <a name="input_image_configs"></a> [image\_configs](#input\_image\_configs) | Resource configurations for the service containers | <pre>object({<br/>    cpu    = optional(number, 256)<br/>    memory = optional(number, 512)<br/>    storage = optional(number, 21)<br/>  })</pre> | `{}` | no |
| <a name="input_image_tag"></a> [image\_tag](#input\_image\_tag) | Version of the app in ECR to deploy | `string` | `null` | no |
| <a name="input_lb"></a> [lb](#input\_lb) | Load balancer configuration for the service if there is one | <pre>object({<br/>    vpc_id        = optional(string, null)<br/>    subnets       = optional(list(string), null)<br/>    ingress_cidrs = optional(list(string), ["0.0.0.0/0"])<br/>    # ingress_groups <br/>    egress_cidrs = optional(list(string), ["0.0.0.0/0"])<br/>    # egress_groups<br/>    type                = optional(string, "application")<br/>    internal            = optional(bool, false)<br/>    deletion_protection = optional(bool, false)<br/>    port_mappings = list(object({<br/>      listen_port  = number<br/>      sg_protocol  = optional(string, "tcp")<br/>      lb_protocol  = optional(string, "HTTPS")<br/>      forward_port = number<br/>      tg_protocol  = optional(string, "HTTPS")<br/>      cert         = optional(string, null)<br/>      target_type  = optional(string, "ip")<br/>      health_check = optional(object({<br/>        enabled             = optional(bool, true)<br/>        matcher             = optional(string, "200-499")<br/>        interval            = optional(number, 30)<br/>        healthy_threshold   = optional(number, 2)<br/>        unhealthy_threshold = optional(number, 4)<br/>        service_protocol    = optional(string, "HTTPS")<br/>        path                = optional(string, "/")<br/>      }), {})<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_log_retention"></a> [log\_retention](#input\_log\_retention) | Number of days to store the service logs for | `number` | `7` | no |
| <a name="input_propagate_tags"></a> [propagate\_tags](#input\_propagate\_tags) | Should the tags from the task definition propagate to the instances | `string` | `null` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | List of secrets to attach to the service | `list(map(string))` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources. Ie: environment, cost tracking, etc... | `map(any)` | `{}` | no |
| <a name="input_target_groups"></a> [target\_groups](#input\_target\_groups) | List of existing target groups to associate with the service | <pre>list(object({<br/>    arn            = string<br/>    container_port = number<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cname_target"></a> [cname\_target](#output\_cname\_target) | DNS CNAME of the load balancer to reach in order to talk to the service |
| <a name="output_sg_id"></a> [sg\_id](#output\_sg\_id) | ID of the created security group if there is one |  
<!-- END_TF_DOCS -->