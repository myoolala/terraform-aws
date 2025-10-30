####################################################################################################
####################                            Networks                       ####################
####################################################################################################

module "sg" {
  count  = var.vpc_config != null && var.vpc_config.create_sg ? 1 : 0
  source = "../security-group"

  name   = "${var.name}-access"
  vpc_id = var.vpc_config.vpc_id
}

locals {
  provided_sgs = var.vpc_config != null ? var.vpc_config.sg_ids : []
  sg_ids = concat(local.provided_sgs, module.sg[*].id)
}

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
  name               = "codebuild-${var.name}"
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

        values = var.vpc_config.subnet_arns
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

  # @TODO? idk if this is something I care about yet
  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type     = var.cache.type
    location = var.cache.location
    modes    = var.cache.modes
  }

  environment {
    compute_type                = var.environment.compute_type
    image                       = var.environment.image
    type                        = var.environment.type
    image_pull_credentials_type = var.environment.image_pull_credentials_type
    privileged_mode             = var.environment.privileged_mode

    dynamic "environment_variable" {
      for_each = var.environment.environment_variables

      content {
        name  = environment_variable.value.name
        value = environment_variable.value.value
        type  = environment_variable.value.type
      }
    }
  }

  logs_config {
    dynamic "cloudwatch_logs" {
      for_each = var.cw_log_config != null ? [1] : []

      content {
        group_name  = var.cw_log_config.group_name != null ? var.cw_log_config.group_name : "codebuild-${var.name}"
        stream_name = var.cw_log_config.stream_name
      }
    }

    s3_logs {
      status              = var.s3_log_config.status
      location            = var.s3_log_config.location
      encryption_disabled = !var.s3_log_config.encrypted
      bucket_owner_access = var.s3_log_config.bucket_owner_access
    }
  }

  source {
    type      = var.source_config.type
    buildspec = var.source_config.buildspec
  }

  dynamic "vpc_config" {
    for_each = var.vpc_config != null ? [1] : []

    content {
      vpc_id             = var.vpc_config.vpc_id
      subnets            = var.vpc_config.subnet_ids
      security_group_ids = local.sg_ids
    }
  }

  tags = var.default_tags
}