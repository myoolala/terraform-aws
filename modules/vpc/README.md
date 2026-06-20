<!-- BEGIN_TF_DOCS -->
# VPC

Creates a VPC in a variety of configurations. This primarily supports the ingress/public and compute/private subnet idea but supports an arbitrary number of subnets types.

There are integrations for mapping NAT Gateways to AZ's, conditionally creating Internet Gateways, enabling IPV6 or 4


## Example of a minimally set public IPV4 VPC:
```hcl
module "example_pipeline" {
  source = "github.com/myoolala/terraform-aws/modules//vpc"

  name ="my-vpc"
  public = true
  ipv4_cidr = "172.31.0.0/16"
  ingress_subnets = [{
    ipv4_cidr = "172.31.0.0/27"
    az = "us-east-1a"
    nat = true
  },
  {
    ipv4_cidr = "172.31.0.32/27"
    az = "us-east-1b"
    nat = true
  }]
  compute_subnets = [{
    ipv4_cidr = "172.31.1.0/25"
    az = "us-east-1a"
  },
  {
    ipv4_cidr = "172.31.1.128/25"
    az = "us-east-1b"
  }]
  }
```

[More examples can be found here](../../tests/vpc/)

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Requirements

No requirements.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ipv4_cidr"></a> [ipv4\_cidr](#input\_ipv4\_cidr) | IPV4 CIDR for the VPC | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name to apply to the VPC for reference | `string` | n/a | yes |
| <a name="input_compute_subnets"></a> [compute\_subnets](#input\_compute\_subnets) | List of compute subnets to create for the vpc | <pre>list(object({<br/>    ipv4_cidr             = optional(string, null)<br/>    a_record_on_launch    = optional(bool, false)<br/>    ipv6_block_size       = optional(number, null)<br/>    ipv6_block            = optional(number, null)<br/>    ipv6_native           = optional(bool, false)<br/>    aaaa_record_on_launch = optional(bool, false)<br/>    enable_dns64          = optional(bool, false)<br/>    az                    = string<br/>  }))</pre> | `[]` | no |
| <a name="input_enable_dns_hostnames"></a> [enable\_dns\_hostnames](#input\_enable\_dns\_hostnames) | Enabled DNS hostnames in the vpc | `bool` | `true` | no |
| <a name="input_enable_dns_support"></a> [enable\_dns\_support](#input\_enable\_dns\_support) | Enabled DNS support in the vpc | `bool` | `true` | no |
| <a name="input_flow_logs"></a> [flow\_logs](#input\_flow\_logs) | Enable or disable flow logs with or without encryption | <pre>object({<br/>    enabled      = optional(bool, true)<br/>    traffic_type = optional(string, "ALL")<br/>    # Default alias for aws cloudwatch kms key<br/>    kms_key_arn   = optional(string, null)<br/>    kms_key_alias = optional(string, null)<br/>    # flow_log_role = optional(string, null)<br/>    log_group = optional(string, null)<br/>  })</pre> | <pre>{<br/>  "enabled": false<br/>}</pre> | no |
| <a name="input_gateway_endpoints"></a> [gateway\_endpoints](#input\_gateway\_endpoints) | List of gateway endpoints to deploy if any. Defaults to all since they are free | `list(string)` | <pre>[<br/>  "s3",<br/>  "dynamodb"<br/>]</pre> | no |
| <a name="input_ingress_subnets"></a> [ingress\_subnets](#input\_ingress\_subnets) | List of ingress subnets to create for the vpc. These CIDRs should be small | <pre>list(object({<br/>    ipv4_cidr             = optional(string, null)<br/>    a_record_on_launch    = optional(bool, false)<br/>    ipv6_block_size       = optional(number, null)<br/>    ipv6_block            = optional(number, null)<br/>    ipv6_native           = optional(bool, false)<br/>    aaaa_record_on_launch = optional(bool, false)<br/>    enable_dns64          = optional(bool, false)<br/>    az                    = string<br/>    nat                   = optional(bool, false)<br/>  }))</pre> | `[]` | no |
| <a name="input_instance_tenancy"></a> [instance\_tenancy](#input\_instance\_tenancy) | Desired Tenancy for the vpc | `string` | `"default"` | no |
| <a name="input_ipv6_conf"></a> [ipv6\_conf](#input\_ipv6\_conf) | Netmask length for a public ipv6 config. 44 to 60 in increments of 4 | <pre>object({<br/>    border_group = string<br/>  })</pre> | `null` | no |
| <a name="input_nat_azs"></a> [nat\_azs](#input\_nat\_azs) | List of AZ's to deploy nat gateways to if the vpc is public and has compute subnets | `list(string)` | `[]` | no |
| <a name="input_other_subnets"></a> [other\_subnets](#input\_other\_subnets) | List of other subnets to create for the vpc, like db subnets or endpoint subnets | <pre>map(list(object({<br/>    ipv4_cidr             = optional(string, null)<br/>    a_record_on_launch    = optional(bool, false)<br/>    ipv6_block_size       = optional(number, null)<br/>    ipv6_block            = optional(number, null)<br/>    ipv6_native           = optional(bool, false)<br/>    aaaa_record_on_launch = optional(bool, false)<br/>    enable_dns64          = optional(bool, false)<br/>    az                    = string<br/>  })))</pre> | `{}` | no |
| <a name="input_public"></a> [public](#input\_public) | Make the vpc accessible from the internet | `bool` | `false` | no |
| <a name="input_secondary_ipv4_cidrs"></a> [secondary\_ipv4\_cidrs](#input\_secondary\_ipv4\_cidrs) | Additional IPV4 CIDR's to add to the vpc | `list(string)` | `[]` | no |
| <a name="input_secondary_ipv6_cidrs"></a> [secondary\_ipv6\_cidrs](#input\_secondary\_ipv6\_cidrs) | Additional IPV6 CIDR's to add to the vpc | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_compute_subnet_arns"></a> [compute\_subnet\_arns](#output\_compute\_subnet\_arns) | ARNs of the compute subnets |
| <a name="output_compute_subnet_ids"></a> [compute\_subnet\_ids](#output\_compute\_subnet\_ids) | IDs of the compute subnets |
| <a name="output_compute_subnet_route_mapping"></a> [compute\_subnet\_route\_mapping](#output\_compute\_subnet\_route\_mapping) | Compute subnet route mapping object for the Route Tables |
| <a name="output_default_nacl_id"></a> [default\_nacl\_id](#output\_default\_nacl\_id) | ID of the default NACL |
| <a name="output_default_route_table_id"></a> [default\_route\_table\_id](#output\_default\_route\_table\_id) | ID of the default Route Table |
| <a name="output_ingress_subnet_arns"></a> [ingress\_subnet\_arns](#output\_ingress\_subnet\_arns) | ARNs of the ingress subnets |
| <a name="output_ingress_subnet_ids"></a> [ingress\_subnet\_ids](#output\_ingress\_subnet\_ids) | IDs of the ingress subnets |
| <a name="output_ipv4_cidrs"></a> [ipv4\_cidrs](#output\_ipv4\_cidrs) | IPV4 CIDR ranges in the VPC |
| <a name="output_ipv6_assoc_id"></a> [ipv6\_assoc\_id](#output\_ipv6\_assoc\_id) | Assotication ID for the IPV6 block |
| <a name="output_ipv6_cidr"></a> [ipv6\_cidr](#output\_ipv6\_cidr) | IPV6 cidr range for the VPC |
| <a name="output_nat_az_map"></a> [nat\_az\_map](#output\_nat\_az\_map) | NAT Gateway to AZ mapping object |
| <a name="output_nat_subnet_map"></a> [nat\_subnet\_map](#output\_nat\_subnet\_map) | Mapping of subnets to NAT Gateways |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | IP of the VPC |  
<!-- END_TF_DOCS -->