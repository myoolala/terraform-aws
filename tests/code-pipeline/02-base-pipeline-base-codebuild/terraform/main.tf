resource "aws_codestarconnections_connection" "code_source" {
  name          = "test-code-pipeline-integration-2"
  provider_type = "GitHub"
}

module "base_pipeline" {
  source = "../../../../modules/code-pipeline"

  name = "base-test-minimal-config"
  artifact_store = {
    create      = true
    kms_key_arn = "aws/s3"
  }
  stages = [{
    name             = "Source"
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
    }, {
    name             = "Build"
    category         = "Build"
    owner            = "AWS"
    provider         = "CodeBuild"
    input_artifacts  = ["source_output"]
    output_artifacts = ["build2_output"]
    version          = "1"
    codebuild_project = {
      create         = true
      name           = "test2"
      description    = "Example build project"
      buildspec_path = file("${path.module}/buildspecs/buildspec.yml")
      environment_variables = [{
        name  = "fu"
        value = "bar"
      }]
      vpc_config = null
    }

    configuration = {
      ProjectName = "test2"
    }
  }]
}