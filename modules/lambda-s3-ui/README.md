<!-- BEGIN_TF_DOCS -->
# Lambda S3 UI

Creates a Lambda based S3 proxy sitting behind an ALB to handle UI requests. The main intention is to add logic for SPA apps where a 404 isn't necessarily a 404

This is intended for small or burst scale where a fargate service cannot compete in price

## Key notes:

- If your system is 100% internal, you will need a VPC endpoint such that the target group can reach the Lambda service. 
- In addition, the lambda itself will need a VPC endpoint if it lives inside a private only network to reach s3
- Otherwise, hosting this in a VPC is not required
- All responses are cache via a configuration
- Cache busting headers will bust the in memory RunTime cache
- If you are using multiple hosts on the load balancer, you can enable embedded metrics per host to see the count per site
- There are options for gzip compression to:
  - Support larger possible files since the ALB has a 1MB limit
  - Improve response times for files
  - Reduce ALB bandwidth costs

## Examples:

```hcl
  resource "aws_lb_target_group" "forwarder" {
    name        = "tg_name"
    protocol    = "HTTPS"
    vpc_id      = null
    target_type = "lambda"
  }

  module "lambda-ui" {
    source = "github.com/myoolala/terraform-aws/modules/lambda-s3-ui"

    lambda_name = "ui-lambda"
    alb_tg_arn  = aws_lb_target_group.forwarder.arn
    config = {
      bucket = "fu"
      prefix = "bar"
    }
    vpc_config = null
  }
```

[More examples can be found here](../../tests/ui-lambda)

## The GZIP compression

The lambda will automatically GZIP responses when:
- The feature is enabled
- The response payload is big enough
- The requester states they accept gzip

Special consideration is that even when the requester accepts a gzip payload, one might not be returned
if the data is not ready. This is because in the background of the request is when the gzip occurs and can
take a while. I've seen excess of 1 second for large files. So if the file does not NEED to be gzip'd and
the gzip is not finished yet, a raw version is returned instead.

If you still have large wait times as the raw payloads are in excess of 1MB, consider increasing the CPU

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | n/a |
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Requirements

No requirements.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_tg_arn"></a> [alb\_tg\_arn](#input\_alb\_tg\_arn) | ARN of the ALB Target group that forward requests to the lambda | `string` | n/a | yes |
| <a name="input_config"></a> [config](#input\_config) | Configuration for the lambda function code | <pre>object({<br/>    bucket                   = string,<br/>    prefix                   = string,<br/>    storage_kms_keys         = optional(list(string), [])<br/>    log_level                = optional(string, "INFO"),<br/>    gz_assets                = optional(bool, false)<br/>    cache_mapping            = optional(map(any), null)<br/>    server_cache_ms          = optional(number, 5 * 60 * 1000)<br/>    enable_spa               = optional(bool, false)<br/>    default_file_path        = optional(string, "index.html")<br/>    default_response_headers = optional(map(any), null)<br/>  })</pre> | n/a | yes |
| <a name="input_lambda_name"></a> [lambda\_name](#input\_lambda\_name) | Name for the lambda function | `string` | n/a | yes |
| <a name="input_auto_gzip_compress"></a> [auto\_gzip\_compress](#input\_auto\_gzip\_compress) | Have the lambda return a GZIP'd compressed payload back to the load balancer. This is most ideal for large dependency files that exceed 1MB | `bool` | `true` | no |
| <a name="input_bucket_key"></a> [bucket\_key](#input\_bucket\_key) | S3 URI for the lambda zip file | `string` | `null` | no |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Name of the bucket the code will be stored in | `string` | `null` | no |
| <a name="input_environment_vars"></a> [environment\_vars](#input\_environment\_vars) | Environment variables to pass into the lambda | `map(string)` | `null` | no |
| <a name="input_metrics_config"></a> [metrics\_config](#input\_metrics\_config) | Whether the lambda should create an embbeded metric for the domain that was hit | <pre>object({<br/>    enabled   = bool<br/>    namespace = optional(string, null)<br/>  })</pre> | <pre>{<br/>  "enabled": false<br/>}</pre> | no |
| <a name="input_sg_config"></a> [sg\_config](#input\_sg\_config) | Existing security group to use if there is one | <pre>object({<br/>    create = bool<br/>    vpc_id = string<br/>    # Default is fine if the lambda is internal but sends responses over the internet,<br/>    # narrow it down when using VPC endpoints<br/>    egress_cidrs = optional(list(string), ["0.0.0.0/0"])<br/>    egress_sgs   = optional(list(string), [])<br/>  })</pre> | <pre>{<br/>  "create": false,<br/>  "vpc_id": null<br/>}</pre> | no |
| <a name="input_vpc_config"></a> [vpc\_config](#input\_vpc\_config) | VPC config to use | <pre>object({<br/>    subnets = list(string)<br/>    sg_ids  = optional(list(string), [])<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_function_name"></a> [function\_name](#output\_function\_name) | Name of the Lambda function |
| <a name="output_sg_id"></a> [sg\_id](#output\_sg\_id) | Security group ID created if one was created |  
<!-- END_TF_DOCS -->