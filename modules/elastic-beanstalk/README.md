# Elastic Beanstalk Module

This module provisions an AWS Elastic Beanstalk application, an application version, and an environment.

## Features
- Deploys Node.js or .NET applications via bundled ZIP archives.
- Supports local source bundles (auto‑uploaded to a new or existing S3 bucket).
- Optionally creates an S3 bucket for the bundle.
- Exposes convenient outputs for downstream modules.

## Usage
```hcl
module "eb" {
  source = "module/elastic-beanstalk"

  application_name          = "my-app"
  solution_stack_name       = "64bit Amazon Linux 2 v3.3.6 running Node.js 16"
  environment_name          = "prod"
  application_version_label = "v1"

  s3_bucket = "my-bucket"
  s3_key    = "my-app.zip"

  tags = {
    Environment = "Production"
  }
}
```

## Inputs
| Variable | Description | Type | Default |
|----------|-------------|------|---------|
| application_name | Name of the Elastic Beanstalk application. | string | N/A |
| solution_stack_name | Elastic Beanstalk solution stack. | string | N/A |
| environment_name | Name of the environment; defaults to `application_name`. | string | null |
| application_version_label | Label for the application version. | string | timestamped |
| source_code_path | Path to local source for an auto‑uploaded bundle. | string | null |
| s3_bucket | S3 bucket containing the bundle. | string | null |
| s3_key | S3 key of the bundle. | string | null |
| create_bucket | Create a new bucket when uploading a local bundle. | bool | true |
| tags | Map of tags. | map(string) | {} |

## Outputs
- `application_name`
- `environment_name`
- `application_version_label`
- `s3_bucket`
- `s3_key`


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.53.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | n/a |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.53.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [archive_file.bundle](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/resources/file) | resource |
| [aws_elastic_beanstalk_application.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elastic_beanstalk_application) | resource |
| [aws_elastic_beanstalk_application_version.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elastic_beanstalk_application_version) | resource |
| [aws_elastic_beanstalk_environment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elastic_beanstalk_environment) | resource |
| [aws_s3_bucket.bundle_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_object.bundle_obj](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [random_id.bucket_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_name"></a> [application\_name](#input\_application\_name) | The name of the Elastic Beanstalk application. | `string` | n/a | yes |
| <a name="input_application_version_label"></a> [application\_version\_label](#input\_application\_version\_label) | Label of the application version. If omitted, a timestamped value will be used. | `string` | `null` | no |
| <a name="input_create_bucket"></a> [create\_bucket](#input\_create\_bucket) | Whether to create a new S3 bucket for the bundle when source\_code\_path is provided. | `bool` | `true` | no |
| <a name="input_environment_name"></a> [environment\_name](#input\_environment\_name) | Name of the Elastic Beanstalk environment. Defaults to application\_name. | `string` | `null` | no |
| <a name="input_instance_types"></a> [instance\_types](#input\_instance\_types) | Allowed EC2 instance types, in priority order. | `list(string)` | n/a | yes |
| <a name="input_s3_bucket"></a> [s3\_bucket](#input\_s3\_bucket) | S3 bucket where the application bundle is stored. Required if source\_code\_path is not provided. | `string` | `null` | no |
| <a name="input_s3_key"></a> [s3\_key](#input\_s3\_key) | S3 key for the application bundle. Required if source\_code\_path is not provided. | `string` | `null` | no |
| <a name="input_settings"></a> [settings](#input\_settings) | Additional Beanstalk settings, grouped by namespace. | `map(map(string))` | `{}` | no |
| <a name="input_solution_stack_name"></a> [solution\_stack\_name](#input\_solution\_stack\_name) | The name of the solution stack for the environment. | `string` | n/a | yes |
| <a name="input_source_code_path"></a> [source\_code\_path](#input\_source\_code\_path) | Local directory path to source code for creating a bundle. Not required when using pre-uploaded S3 objects. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags to apply to resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_application_name"></a> [application\_name](#output\_application\_name) | Name of the Elastic Beanstalk application. |
| <a name="output_application_version_label"></a> [application\_version\_label](#output\_application\_version\_label) | Label of the deployed application version. |
| <a name="output_environment_name"></a> [environment\_name](#output\_environment\_name) | Name of the Elastic Beanstalk environment. |
| <a name="output_s3_bucket"></a> [s3\_bucket](#output\_s3\_bucket) | S3 bucket containing the application bundle. |
| <a name="output_s3_key"></a> [s3\_key](#output\_s3\_key) | S3 key of the application bundle. |
<!-- END_TF_DOCS -->