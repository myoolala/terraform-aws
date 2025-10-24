resource "aws_codestarconnections_connection" "code_source" {
  name = "test-code-pipeline-integration-1"
  provider_type          = "GitHub"
}

module "base_pipeline" {
    source = "../../../../modules/code-pipeline"

    name = "base-test-minimal-config"
    artifact_store = {
        create = true
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

      configuration = {
        ProjectName = "test2"
      }
    }]
}