<!-- BEGIN_TF_DOCS -->
# Serverless App

Creates an entire lambda based application using CloudFront, API Gateway, and S3.

This is meant to act as a starting place or run simple applications

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Requirements

No requirements.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_code_bucket_name"></a> [api\_code\_bucket\_name](#input\_api\_code\_bucket\_name) | Name of the bucket to store the backend code in | `string` | n/a | yes |
| <a name="input_cname"></a> [cname](#input\_cname) | CNAME for the site that is being hosted | `string` | n/a | yes |
| <a name="input_s3_prefix"></a> [s3\_prefix](#input\_s3\_prefix) | Path in S3 the ui is stored in | `string` | n/a | yes |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | Name of the application you are deploying | `string` | n/a | yes |
| <a name="input_ui_bucket_name"></a> [ui\_bucket\_name](#input\_ui\_bucket\_name) | Name of the bucket to house the publicly reachable files | `string` | n/a | yes |
| <a name="input_acm_arn"></a> [acm\_arn](#input\_acm\_arn) | ARN of the aws cert to attach to cloudfront if desired | `string` | `null` | no |
| <a name="input_addition_function_configs"></a> [addition\_function\_configs](#input\_addition\_function\_configs) | Addition configs for all of the lambdas to have | <pre>map(object({<br/>    permissions = map(any)<br/>    secrets     = set(string)<br/>    env_vars    = map(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_create_ui_bucket"></a> [create\_ui\_bucket](#input\_create\_ui\_bucket) | Create a new bucket to house the UI code in | `bool` | `true` | no |
| <a name="input_function_configs"></a> [function\_configs](#input\_function\_configs) | Config for all of the lambdas to produce | <pre>map(object({<br/>    s3Uri  = string<br/>    routes = set(string)<br/>    prefix = string<br/>  }))</pre> | `{}` | no |
| <a name="input_make_new_lambda_bucket"></a> [make\_new\_lambda\_bucket](#input\_make\_new\_lambda\_bucket) | Check whether to create a new api code bucket or use an existing one | `bool` | `true` | no |
| <a name="input_protocol"></a> [protocol](#input\_protocol) | Protocol for the lambda api | `string` | `"HTTP"` | no |
| <a name="input_region"></a> [region](#input\_region) | Region being deployed in AWS | `string` | `"us-east-1"` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | List of secrets to attach to the service | `list(map(string))` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudfront_domain_name"></a> [cloudfront\_domain\_name](#output\_cloudfront\_domain\_name) | Domain name for the CloudFront distro |  
<!-- END_TF_DOCS -->