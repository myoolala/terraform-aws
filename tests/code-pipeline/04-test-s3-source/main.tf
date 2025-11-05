resource "random_string" "suffix" {
  length  = 8
  special = false # Set to true to include special characters
  numeric = false # Set to true to include numbers
  upper   = false # Set to true to include uppercase letters
  lower   = true  # Set to true to include lowercase letters
}

module "source_bucket" {
  source = "../../../modules/s3-bucket"

  name               = "test-integration-${random_string.suffix.result}"
  versioning_enabled = true
}

output "source_bucket" {
  value = module.source_bucket.id
}

data "aws_kms_key" "default_s3_key" {
  key_id = "alias/aws/s3"
}

module "base_pipeline" {
  source = "../../../modules/code-pipeline"

  name = "base-test-minimal-config"
  artifact_store = {
    create      = true
    kms_key_arn = "alias/aws/s3"
  }
  permissions = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "s3:*"
      Effect = "Allow"
      Resource = [
        # @TODO: fix this to not be star resources
        "*"
        # module.source_bucket.arn,
        # "${module.source_bucket.arn}/*"
      ]
      }
    ]
  })
  stages = [{
    name             = "Source"
    category         = "Source"
    owner            = "AWS"
    provider         = "S3"
    version          = "1"
    output_artifacts = ["source_output"]

    # @Link: https://docs.aws.amazon.com/codepipeline/latest/userguide/action-reference-S3.html
    configuration = {
      S3Bucket    = module.source_bucket.id
      S3ObjectKey = "index.zip"
    }
    }, {
    name             = "Build"
    category         = "Build"
    owner            = "AWS"
    provider         = "CodeBuild"
    input_artifacts  = ["source_output"]
    output_artifacts = ["build_output"]
    version          = "1"
    codebuild_project = {
      create         = true
      name           = "test2"
      description    = "Example build project"
      buildspec_path = file("${path.module}/buildspecs/build.yml")
      environment_variables = [{
        name  = "fu"
        value = "bar"
      }]
      vpc_config = null
    }

    configuration = {
      ProjectName = "test2"
    }
    }, {
    name            = "Deploy"
    category        = "Build"
    owner           = "AWS"
    provider        = "CodeBuild"
    input_artifacts = ["build_output"]
    version         = "1"
    codebuild_project = {
      create         = true
      name           = "test3"
      description    = "Example build project"
      buildspec_path = file("${path.module}/buildspecs/build2.yml")
      environment_variables = [{
        name  = "fu"
        value = "bar"
      }]
      vpc_config = null
    }

    configuration = {
      ProjectName = "test3"
    }
  }]

  depends_on = [
    module.source_bucket
  ]
}

resource "archive_file" "source" {
  type        = "zip"
  source_file = abspath("${path.module}/index.html")
  output_path = abspath("${path.module}/index.zip")
}

data "aws_kms_alias" "s3" {
  name = "alias/aws/s3"
}

resource "aws_s3_object" "object" {
  bucket     = module.source_bucket.id
  key        = "index.zip"
  source     = archive_file.source.output_path
  kms_key_id = data.aws_kms_alias.s3.arn

  depends_on = [
    module.base_pipeline
  ]
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Environment = "tf-integration-test"
      Billing     = "tf-integration-test"
    }
  }
}