<!-- BEGIN_TF_DOCS -->
# Index Containers service

This deploys a background service that listens for pushed containers to ECR and will then go and index them via [SOCI](https://github.com/awslabs/soci-snapshotter?tab=readme-ov-file)

This is to implement lazy loading of containers to increase autoscaling speed in an all in one module

# Examples

## Base deployment

```hcl
module "index_ecr_containers" {
  source = "github.com/myoolala/terraform-aws//modules/index-containers"

  name = "us-east-1-index-containers"
  vpc = {
    id = "vpc-01234567890123456"
    subnets = [
      "subnet-01234567890123456",
      "subnet-65432109876543210"
    ]
  }
  cluster = {
    create = true
    name = "index-containers-with-soci"
  }
}
```

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Requirements

No requirements.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster"></a> [cluster](#input\_cluster) | Cluster configuration to attach to the scheduled task | <pre>object({<br/>    create = optional(bool, true)<br/>    name   = optional(string, null)<br/>    arn    = optional(string, null)<br/>  })</pre> | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name for the SOCI image indexer | `string` | n/a | yes |
| <a name="input_vpc"></a> [vpc](#input\_vpc) | VPC configuration to host the Fargate task in | <pre>object({<br/>    id      = string<br/>    subnets = list(string)<br/>  })</pre> | n/a | yes |
| <a name="input_code_bucket_config"></a> [code\_bucket\_config](#input\_code\_bucket\_config) | Existing code bucket to use if there is one | <pre>object({<br/>    id     = string<br/>    arn    = string<br/>    prefix = string<br/>  })</pre> | `null` | no |
| <a name="input_event_filter_override"></a> [event\_filter\_override](#input\_event\_filter\_override) | JSON encoded filter to use in place of the default event filter | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources in the module | `map(string)` | `{}` | no |

## Outputs

No outputs.  
<!-- END_TF_DOCS -->