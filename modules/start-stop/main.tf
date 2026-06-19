data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

locals {
  region    = data.aws_region.current.region
  acct      = data.aws_caller_identity.current.account_id
  partition = data.aws_partition.current.partition

  default_permissions = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "EcsAccess"
        Action = [
          "ecs:DescribeServices",
          "ecs:ListClusters",
          "ecs:ListServices",
          "ecs:UpdateService"
        ]
        Effect   = "Allow"
        Resource = ["*"]
      },
      {
        Sid = "RdsAccess"
        "Effect" : "Allow",
        "Action" : [
          "rds:DescribeDBInstances",
          "rds:ListTagsForResource",
          "rds:StartDBInstance",
          "rds:StopDBInstance"
        ],
        "Resource" : "arn:${local.partition}:rds:${local.region}:${local.acct}:db:*"
      },
      {
        Sid    = "AsgAccess"
        Effect = "Allow"
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "ec2:DescribeInstances",
          "events:ListRules"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "archive_file" "source" {
  type        = "zip"
  source_file = abspath("${path.module}/code/index.js")
  output_path = abspath("${path.module}/output/lambda.zip")
}

module "start_stop" {
  source = "../lambda"

  file_path    = archive_file.source.output_path
  code_hash256 = archive_file.source.output_base64sha256
  environment_vars = {
    LOG_LEVEL  = var.log_level
    DRY_RUN    = var.dry_run_mode_enabled
    TAG_LOOKUP = var.tag_to_search
  }
  log_retention = var.log_retention
  permissions   = var.permissions != null ? var.permissions : local.default_permissions
  runtime       = "nodejs22.x"
  function_name = var.name
  memory        = var.memory
  timeout       = var.timeout
  handler       = "index.handler"
  schedule      = var.schedule
}

resource "aws_cloudwatch_metric_alarm" "failed_to_start_stop" {
  count = length(var.sns_alert_topics) > 0 ? 1 : 0

  alarm_name          = "${var.name}-failed-to-run"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  dimensions = {
    FunctionName = module.start_stop.function_name
  }
  period            = 60
  statistic         = "Sum"
  threshold         = 1
  alarm_description = "This checks for any errors relating to start stop to scream to the dev team about"
  alarm_actions     = var.sns_alert_topics
}