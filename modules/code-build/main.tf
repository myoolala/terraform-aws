####################################################################################################
####################                           Permissions                      ####################
####################################################################################################

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "main" {
  name               = "main"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "main" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }

  dynamic "statement" {
    for_each = var.vpc_config != null ? [1] : []

    content {
      effect = "Allow"

      actions = [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeDhcpOptions",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeVpcs",
      ]

      resources = ["*"]
    }
  }

  dynamic "statement" {
    for_each = var.vpc_config != null ? [1] : []

    content {
      effect    = "Allow"
      actions   = ["ec2:CreateNetworkInterfacePermission"]
      resources = ["arn:aws:ec2:us-east-1:123456789012:network-interface/*"]

      condition {
        test     = "StringEquals"
        variable = "ec2:Subnet"

        values = [
          aws_subnet.main1.arn,
          aws_subnet.main2.arn,
        ]
      }

      condition {
        test     = "StringEquals"
        variable = "ec2:AuthorizedService"
        values   = ["codebuild.amazonaws.com"]
      }
    }
  }

  #   statement {
  #     effect  = "Allow"
  #     actions = ["s3:*"]
  #     resources = [
  #       aws_s3_bucket.main.arn,
  #       "${aws_s3_bucket.main.arn}/*",
  #     ]
  #   }

  #   statement {
  #     effect = "Allow"
  #     actions = [
  #       "codeconnections:GetConnectionToken",
  #       "codeconnections:GetConnection"
  #     ]
  #     resources = ["arn:aws:codestar-connections:us-east-1:123456789012:connection/guid-string"]
  #   }
}

resource "aws_iam_role_policy" "main" {
  role   = aws_iam_role.main.name
  policy = data.aws_iam_policy_document.main.json
}

####################################################################################################
####################                               Main                         ####################
####################################################################################################

resource "aws_codebuild_project" "main" {
  name          = var.name
  description   = var.description
  build_timeout = var.build_timeout
  service_role  = aws_iam_role.main.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  #   cache {
  #     type     = "S3"
  #     location = aws_s3_bucket.main.bucket
  #   }

  environment {
    compute_type                = var.environment.compute_type
    image                       = var.environment.image
    type                        = var.environment.type
    image_pull_credentials_type = var.environment.image_pull_credentials_type

    dynamic "environment_variable" {
      for_each = var.environment.environment_variables

      content {
        name  = environment_variable.key
        value = environment_variable.value
      }
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name = var.name
      #   stream_name = "log-stream"
    }

    # s3_logs {
    #   status   = "ENABLED"
    #   location = "${aws_s3_bucket.main.id}/build-log"
    # }
  }

  # source {
  #   type            = "GITHUB"
  #   location        = "https://github.com/mitchellh/packer.git"
  #   git_clone_depth = 1

  #   git_submodules_config {
  #     fetch_submodules = true
  #   }
  # }

  # source_version = "master"

  source {
    type      = "NO_SOURCE"
    buildspec = var.buildspec_path
  }

  dynamic "vpc_config" {
    for_each = var.vpc_config != null ? [1] : []

    content {
      vpc_id             = var.vpc_config.vpc_id
      subnets            = var.vpc_config.subnet_ids
      security_group_ids = var.vpc_config.sg_ids
    }
  }

  tags = var.default_tags
}