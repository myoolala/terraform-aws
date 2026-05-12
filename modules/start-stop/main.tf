locals {
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

  environment_vars = {
    LOG_LEVEL = var.log_level
    DRY_RUN   = var.dry_run_mode_enabled
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