<!-- BEGIN_TF_DOCS -->


## Example

Halp

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
| <a name="input_artifact_store"></a> [artifact\_store](#input\_artifact\_store) | Artifact store to use with the pipeline if there is one | <pre>object({<br/>    create      = bool<br/>    bucket_id   = optional(string, null)<br/>    bucket_arn  = optional(string, null)<br/>    kms_key_arn = optional(string, null)<br/>  })</pre> | <pre>{<br/>  "create": false<br/>}</pre> | no |
| <a name="input_iam_role"></a> [iam\_role](#input\_iam\_role) | Existing IAM role to use for the pipeline. Leave null to create one | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name for the pipeline | `string` | n/a | yes |
| <a name="input_permissions"></a> [permissions](#input\_permissions) | Optional json string of permissions to add to the role | `string` | `null` | no |
| <a name="input_stages"></a> [stages](#input\_stages) | List of stages to build and use | <pre>list(object({<br/>    name             = string<br/>    category         = string<br/>    owner            = optional(string, "AWS")<br/>    provider         = string<br/>    input_artifacts  = optional(list(string), [])<br/>    output_artifacts = optional(list(string), [])<br/>    version          = string<br/>    configuration    = map(any)<br/>    codebuild_project = optional(object({<br/>      create         = bool<br/>      name           = optional(string, null)<br/>      description    = optional(string, null)<br/>      buildspec_path = optional(string, null)<br/>      permissions    = optional(string, null)<br/>      environment = optional(object({<br/>        compute_type                = optional(string, "BUILD_GENERAL1_SMALL")<br/>        image                       = optional(string, "aws/codebuild/amazonlinux2-x86_64-standard:5.0")<br/>        type                        = optional(string, "LINUX_CONTAINER")<br/>        image_pull_credentials_type = optional(string, "CODEBUILD")<br/>        privileged_mode             = optional(bool, false)<br/>        environment_variables = optional(list(object({<br/>          name  = string<br/>          value = string<br/>          type  = optional(string, null)<br/>        })), [])<br/>      }), {})<br/>      vpc_config = optional(object({<br/>        vpc_id      = string<br/>        subnet_ids  = list(string)<br/>        subnet_arns = list(string)<br/>        sg_ids      = optional(list(string), [])<br/>        create_sg   = optional(bool, false)<br/>      }), null)<br/>      cache = optional(object({<br/>        type     = string<br/>        location = optional(string, null)<br/>        modes    = optional(list(string), null)<br/>        }), {<br/>        type = "NO_CACHE"<br/>      })<br/>      }), {<br/>      create = false<br/>    })<br/>  }))</pre> | n/a | yes |

## Outputs

No outputs.  
<!-- END_TF_DOCS -->