<!-- BEGIN_TF_DOCS -->
# Load Balancer

Creates a load balancer with listeners and target group pairs.

[Examples can be found here](../../tests/load-balancer/)

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Requirements

No requirements.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Name for the load balancer and associated resources | `string` | n/a | yes |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | List of subnets to host the load balancer in. Recommend at least 2 | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the vpc to host the LB in | `string` | n/a | yes |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Is the load balancer protected from deletion? | `bool` | `false` | no |
| <a name="input_egress_cidrs"></a> [egress\_cidrs](#input\_egress\_cidrs) | List of cidr ingresses to attach to the load balancer | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_egress_groups"></a> [egress\_groups](#input\_egress\_groups) | List of security group ingresses to attach to the load balancer | `list(string)` | `[]` | no |
| <a name="input_idle_timeout"></a> [idle\_timeout](#input\_idle\_timeout) | Number in seconds the load balancer should wait for a response for | `number` | `60` | no |
| <a name="input_ingress_cidrs"></a> [ingress\_cidrs](#input\_ingress\_cidrs) | List of cidr ingresses to attach to the load balancer | `list(string)` | `[]` | no |
| <a name="input_ingress_groups"></a> [ingress\_groups](#input\_ingress\_groups) | List of security group ingresses to attach to the load balancer | `list(string)` | `[]` | no |
| <a name="input_internal"></a> [internal](#input\_internal) | Is the load balancer internal or external | `bool` | `false` | no |
| <a name="input_port_mappings"></a> [port\_mappings](#input\_port\_mappings) | Port listener mappings with associated the load balancer | <pre>list(object({<br/>    listen_port  = number<br/>    sg_protocol  = optional(string, "tcp")<br/>    lb_protocol  = optional(string, "HTTPS")<br/>    forward_port = number<br/>    tg_protocol  = optional(string, "HTTPS")<br/>    cert         = optional(string, null)<br/>    target_type  = optional(string, "ip")<br/>    health_check = optional(object({<br/>      enabled             = optional(bool, true)<br/>      matcher             = optional(string, "200-499")<br/>      interval            = optional(number, 30)<br/>      healthy_threshold   = optional(number, 2)<br/>      unhealthy_threshold = optional(number, 4)<br/>      service_protocol    = optional(string, "HTTPS")<br/>      path                = optional(string, "/")<br/>    }), {})<br/>  }))</pre> | `[]` | no |
| <a name="input_security_group"></a> [security\_group](#input\_security\_group) | Existing security group to use instead of creating one | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Default tags to associate with the resources | `map(string)` | `{}` | no |
| <a name="input_type"></a> [type](#input\_type) | Load balancer type to stand up | `string` | `"application"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dns_name"></a> [dns\_name](#output\_dns\_name) | DNS CNAME for the load balancer |
| <a name="output_lb_arn"></a> [lb\_arn](#output\_lb\_arn) | ARN for the created load balancer |
| <a name="output_listener_arn"></a> [listener\_arn](#output\_listener\_arn) | ARN for the created load balancer listener |
| <a name="output_sg_id"></a> [sg\_id](#output\_sg\_id) | Security Group ID if one was created |
| <a name="output_tg_arns"></a> [tg\_arns](#output\_tg\_arns) | List of Target Group ARNs for the load balancer |  
<!-- END_TF_DOCS -->