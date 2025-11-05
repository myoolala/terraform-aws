<!-- BEGIN_TF_DOCS -->
# CodeBuild

Creates a codebuild project to run a job

If provided, it will appending the build into a vpc with a security group, applying permissions, roles
etc...

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Requirements

No requirements.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_artifact_store"></a> [artifact\_store](#input\_artifact\_store) | Artififact store to use for the codebuild project | <pre>object({<br/>    type         = string<br/>    location     = optional(string, null)<br/>    location_arn = optional(string, null)<br/>    kms_key      = optional(string, null)<br/>  })</pre> | <pre>{<br/>  "type": "NO_ARTIFACTS"<br/>}</pre> | no |
| <a name="input_build_timeout"></a> [build\_timeout](#input\_build\_timeout) | Build timeout for the project in minutes | `number` | `5` | no |
| <a name="input_cache"></a> [cache](#input\_cache) | Cache field for the codebuild project | <pre>object({<br/>    type     = string<br/>    location = optional(string, null)<br/>    modes    = optional(list(string), null)<br/>  })</pre> | <pre>{<br/>  "type": "NO_CACHE"<br/>}</pre> | no |
| <a name="input_cw_log_config"></a> [cw\_log\_config](#input\_cw\_log\_config) | CloudWatch logging config | <pre>object({<br/>    group_name  = optional(string, null)<br/>    stream_name = optional(string, null)<br/>  })</pre> | `{}` | no |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | Default tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_description"></a> [description](#input\_description) | Description for the codebuild project | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment config for the project | <pre>object({<br/>    compute_type                = optional(string, "BUILD_GENERAL1_SMALL")<br/>    image                       = optional(string, "aws/codebuild/amazonlinux2-x86_64-standard:4.0")<br/>    type                        = optional(string, "LINUX_CONTAINER")<br/>    image_pull_credentials_type = optional(string, "CODEBUILD")<br/>    privileged_mode             = optional(bool, false)<br/>    environment_variables = optional(list(object({<br/>      name  = string<br/>      value = string<br/>      type  = optional(string, null)<br/>    })), [])<br/>  })</pre> | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | Name for the pipeline | `string` | n/a | yes |
| <a name="input_permissions"></a> [permissions](#input\_permissions) | Optional json string of permissions to add to the role | `string` | `null` | no |
| <a name="input_s3_log_config"></a> [s3\_log\_config](#input\_s3\_log\_config) | S3 logging config | <pre>object({<br/>    status              = string<br/>    location            = optional(string, null)<br/>    encrypted           = optional(bool, true)<br/>    bucket_owner_access = optional(string, null)<br/>  })</pre> | <pre>{<br/>  "status": "DISABLED"<br/>}</pre> | no |
| <a name="input_source_config"></a> [source\_config](#input\_source\_config) | Source config as per the AWS provider documentation | <pre>object({<br/>    type      = string<br/>    buildspec = optional(string, null)<br/>  })</pre> | n/a | yes |
| <a name="input_vpc_config"></a> [vpc\_config](#input\_vpc\_config) | VPC config to host the system in if there is one | <pre>object({<br/>    vpc_id      = string<br/>    subnet_ids  = list(string)<br/>    subnet_arns = list(string)<br/>    sg_ids      = optional(list(string), [])<br/>    create_sg   = optional(bool, false)<br/>  })</pre> | `null` | no |

## Outputs

No outputs.  
<!-- END_TF_DOCS -->