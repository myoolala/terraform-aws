<!-- BEGIN_TF_DOCS -->
# S3 Site

Creates an S3 based site sitting behind CloudFront

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Requirements

No requirements.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cname"></a> [cname](#input\_cname) | CNAME to use when hosting the site | `string` | n/a | yes |
| <a name="input_host_s3_bucket"></a> [host\_s3\_bucket](#input\_host\_s3\_bucket) | Name of the bucket to host the site from | `string` | n/a | yes |
| <a name="input_acm_arn"></a> [acm\_arn](#input\_acm\_arn) | Arn of an existing acm cert if applicable | `string` | `null` | no |
| <a name="input_apigateway_origins"></a> [apigateway\_origins](#input\_apigateway\_origins) | List of other origins to add to the cloudfront distro | <pre>set(object({<br/>    id           = string<br/>    domain_name  = string<br/>    path_pattern = string<br/>    stage_name   = string<br/>  }))</pre> | `[]` | no |
| <a name="input_create_s3_bucket"></a> [create\_s3\_bucket](#input\_create\_s3\_bucket) | Create a new bucket for hosting the site on or use an existing one | `bool` | `true` | no |
| <a name="input_s3_prefix"></a> [s3\_prefix](#input\_s3\_prefix) | Path in S3 the ui is deployed to | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources. Ie: environment, cost tracking, etc... | `map(any)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudfront_domain_name"></a> [cloudfront\_domain\_name](#output\_cloudfront\_domain\_name) | Domain name for the cloudfront distribution |  
<!-- END_TF_DOCS -->