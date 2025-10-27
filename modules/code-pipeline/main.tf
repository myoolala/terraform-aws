####################################################################################################
####################                             Artifacts                      ####################
####################################################################################################
resource "random_string" "suffix" {
    count = var.artifact_store.create ? 1 : 0

      length  = 8
      special = false # Set to true to include special characters
      numeric = false  # Set to true to include numbers
      upper   = false  # Set to true to include uppercase letters
      lower   = true  # Set to true to include lowercase letters
}

module "artifacts" {
    count = var.artifact_store.create ? 1 : 0
    source = "../s3-bucket"

    name = "${var.name}-${random_string.suffix[0].result}"
    encryption = {
      algorithm = "aws:kms"
      key = var.artifact_store.kms_key_arn
    }
}

locals {
    artifacts_bucket = var.artifact_store.create ? module.artifacts[0].id : var.artifact_store.bucket_id
    artifacts_bucket_arn = var.artifact_store.create ? module.artifacts[0].arn : var.artifact_store.bucket_arn
    artifacts_bucket_kms_key = var.artifact_store.create ? module.artifacts[0].kms_key_arn : var.artifact_store.kms_key_arn
}


####################################################################################################
####################                            Permissions                     ####################
####################################################################################################

data "aws_iam_policy_document" "assume_role" {
    count = var.iam_role == null ? 1 : 0

    statement {
        effect = "Allow"

        principals {
        type        = "Service"
        identifiers = ["codepipeline.amazonaws.com"]
        }

        actions = ["sts:AssumeRole"]
    }
}

resource "aws_iam_role" "codepipeline_role" {
    count = var.iam_role == null ? 1 : 0

    name               = "${var.name}-pipeline"
    assume_role_policy = data.aws_iam_policy_document.assume_role[0].json
}

data "aws_iam_policy_document" "codepipeline_policy" {
    count = var.iam_role == null ? 1 : 0

    dynamic "statement" {
        for_each = local.artifacts_bucket != null ? [1] : []

        content {
            effect = "Allow"

            actions = [
            "s3:GetObject",
            "s3:GetObjectVersion",
            "s3:GetBucketVersioning",
            "s3:PutObjectAcl",
            "s3:PutObject",
            ]

            resources = [
            local.artifacts_bucket_arn,
            "${local.artifacts_bucket_arn}/*"
            ]
        }
    }

    dynamic "statement" {
        for_each = length(var.stages) > 0 && var.stages[0].provider == "CodeStarSourceConnection" ? [1] : []

        content {
            effect    = "Allow"
            actions   = ["codestar-connections:UseConnection"]
            resources = [var.stages[0].configuration.ConnectionArn]
        }
    }

    # Change this? namely set this after the pipeline is made?
  statement {
    effect = "Allow"

    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "codepipeline_policy" {
    count = var.iam_role == null ? 1 : 0
    
  name   = "codepipeline_policy"
  role   = aws_iam_role.codepipeline_role[0].id
  policy = data.aws_iam_policy_document.codepipeline_policy[0].json
}

locals {
    pipeline_role = var.iam_role != null ? var.iam_role : aws_iam_role.codepipeline_role[0].arn
}

####################################################################################################
####################                            The Pipeline                    ####################
####################################################################################################

resource "aws_codepipeline" "this" {
  name     = var.name
  role_arn = local.pipeline_role

    artifact_store {
        location = local.artifacts_bucket
        type     = "S3"

        encryption_key {
            id   = local.artifacts_bucket_kms_key
            # Only KMS is supported currently
            type = "KMS"
        }
    }

    dynamic "stage" {
        for_each = var.stages

        content {
            name = stage.value.name

            action {
                name             = stage.value.name
                category         = stage.value.category
                owner            = stage.value.owner
                provider         = stage.value.provider
                input_artifacts  = stage.value.input_artifacts
                output_artifacts = stage.value.output_artifacts
                version          = stage.value.version

                configuration = stage.value.configuration
            }
        }
    }

    depends_on = [ 
        module.artifacts,
        aws_iam_role.codepipeline_role
    ]
}