resource "archive_file" "source" {
  type        = "zip"
  source_file = abspath("${path.module}/code/index.js")
  output_path = abspath("${path.module}/output/lambda.zip")
}

module "lambda" {
  source = "../lambda"

  function_name  = var.name
  file_path      = archive_file.source.output_path
  schedule       = var.schedule
  schedule_input = jsonencode(var.event_schedule_input)
  environment_vars = {
    ALERTS_TOPIC = var.alerts_topic
    DRY_RUN      = jsonencode(var.dy_run)
    LOG_LEVEL    = var.log_level
  }
  permissions = var.permissions
}