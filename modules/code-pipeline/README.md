<!-- BEGIN_TF_DOCS -->
# CodePipeline

Creates a CodePipeline with a list of stages while autmating the creation the of shared artifacts bucket, codebuild projects if there are any, and any required permissions that might be needed.

## Example of a minimally set pipeline:
```hcl
resource "aws_codestarconnections_connection" "code_source" {
  name          = "my-code-source"
  provider_type = "GitHub"
}

module "example_pipeline" {
  source = "github.com/myoolala/terraform-aws/modules//code-pipeline"

  name = "base-minimal-config"
  artifact_store = {
    create      = true
    kms_key_arn = "aws/s3"
  }
  stages = [{
    name             = "Source"
    actions = [{
      name             = "Git"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.code_source.arn
        FullRepositoryId = "myoolala/terraform-aws"
        BranchName       = "main"
      }
    }]
  }, {
    name             = "Build"
    actions = [{
      name             = "Project"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build2_output"]
      version          = "1"

      configuration = {
        ProjectName = "buildMyCode"
      }
    }]
  }]
}
```

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
| <a name="input_name"></a> [name](#input\_name) | Name for the pipeline | n/a | yes |
| <a name="input_stages"></a> [stages](#input\_stages) | List of stages to build and use | n/a | yes |
| <a name="input_artifact_store"></a> [artifact\_store](#input\_artifact\_store) | Artifact store to use with the pipeline if there is one | <pre>{<br/>  "create": false<br/>}</pre> | no |
| <a name="input_iam_role"></a> [iam\_role](#input\_iam\_role) | Existing IAM role to use for the pipeline. Leave null to create one | `null` | no |
| <a name="input_permissions"></a> [permissions](#input\_permissions) | Optional json string of permissions to add to the role | `null` | no |

## Outputs

No outputs.  
<!-- END_TF_DOCS -->