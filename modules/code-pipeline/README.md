<!-- BEGIN_TF_DOCS -->
# CodePipeline

Creates a CodePipeline with a list of stages while autmating the creation the of shared artifacts bucket, codebuild projects if there are any, and any required permissions that might be needed.

## Examples:

[Click here to view a folder of example tests](../../tests/code-pipeline)

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Requirements

No requirements.

## Inputs

| Name | Description | Default | Required |
|------|-------------|---------|:--------:|
| <a name="input_artifact_store"></a> [artifact\_store](#input\_artifact\_store) | Artifact store to use with the pipeline if there is one | <pre>{<br/>  "create": false<br/>}</pre> | no |
| <a name="input_iam_role"></a> [iam\_role](#input\_iam\_role) | Existing IAM role to use for the pipeline. Leave null to create one | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name for the pipeline | n/a | yes |
| <a name="input_permissions"></a> [permissions](#input\_permissions) | Optional json string of permissions to add to the role | `null` | no |
| <a name="input_stages"></a> [stages](#input\_stages) | List of stages to build and use | n/a | yes |

## Outputs

No outputs.  
<!-- END_TF_DOCS -->