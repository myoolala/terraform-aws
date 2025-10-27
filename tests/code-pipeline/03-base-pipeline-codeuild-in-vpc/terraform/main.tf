module "vpc" {
  source = "../../../../modules/vpc"

  name      = "private-vpc-test"
  ipv4_cidr = "172.31.0.0/16"
  ingress_subnets = [{
    ipv4_cidr = "172.31.0.0/27"
    az        = "us-east-1a"
    },
    {
      ipv4_cidr = "172.31.0.32/27"
      az        = "us-east-1b"
  }]
  compute_subnets = [{
    ipv4_cidr = "172.31.1.0/25"
    az        = "us-east-1a"
    },
    {
      ipv4_cidr = "172.31.1.128/25"
      az        = "us-east-1b"
  }]
}

module "sg" {
  source = "../../../../modules/security-group"

  name   = "test-for-codebuild"
  vpc_id = module.vpc.vpc_id
}

resource "aws_codestarconnections_connection" "code_source" {
  name          = "test-code-pipeline-integration-3"
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
    output_artifacts = ["build_output"]
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
      vpc_config = {
        vpc_id      = module.vpc.vpc_id
        subnet_ids  = module.vpc.compute_subnet_ids
        subnet_arns = module.vpc.compute_subnet_arns
        sg_ids      = [module.sg.id]
        create_sg   = false
      }
    }

    configuration = {
      ProjectName = "test2"
    }
    }, {
    name             = "Build2"
    category         = "Build"
    owner            = "AWS"
    provider         = "CodeBuild"
    input_artifacts  = ["build_output"]
    output_artifacts = ["build2_output"]
    version          = "1"
    codebuild_project = {
      create         = true
      name           = "test3"
      description    = "Example build project"
      buildspec_path = file("${path.module}/buildspecs/buildspec.yml")
      environment_variables = [{
        name  = "fu"
        value = "bar"
      }]
      vpc_config = {
        vpc_id      = module.vpc.vpc_id
        subnet_ids  = module.vpc.compute_subnet_ids
        subnet_arns = module.vpc.compute_subnet_arns
        sg_ids      = []
        create_sg   = true
      }
    }

    configuration = {
      ProjectName = "test3"
    }
    }, {
    name             = "Build3"
    category         = "Build"
    owner            = "AWS"
    provider         = "CodeBuild"
    input_artifacts  = ["build2_output"]
    output_artifacts = ["build3_output"]
    version          = "1"
    codebuild_project = {
      create         = true
      name           = "test4"
      description    = "Example build project"
      buildspec_path = file("${path.module}/buildspecs/buildspec.yml")
      environment_variables = [{
        name  = "fu"
        value = "bar"
      }]
      vpc_config = {
        vpc_id      = module.vpc.vpc_id
        subnet_ids  = module.vpc.compute_subnet_ids
        subnet_arns = module.vpc.compute_subnet_arns
        sg_ids      = [module.sg.id]
        create_sg   = true
      }
    }

    configuration = {
      ProjectName = "test4"
    }
  }]

  depends_on = [
    module.vpc,
    module.sg
  ]
}