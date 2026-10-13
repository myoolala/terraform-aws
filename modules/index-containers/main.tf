data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

locals {
  region   = data.aws_region.current.region
  zip_name = "1234"
}

##################################################################
##########                   Code Bucket                ##########
##################################################################
resource "random_string" "suffix" {
  length  = 8
  special = false # Set to true to include special characters
  numeric = true  # Set to true to include numbers
  upper   = false # Set to true to include uppercase letters
  lower   = true  # Set to true to include lowercase letters
}

module "code_bucket" {
  count  = var.code_bucket_config == null ? 1 : 0
  source = "../s3-bucket"

  name = "${var.name}-${random_string.suffix.result}"
}

locals {
  source_bucket = {
    id     = var.code_bucket_config != null ? var.code_bucket_config.id : module.code_bucket[0].id
    arn    = var.code_bucket_config != null ? var.code_bucket_config.arn : module.code_bucket[0].arn
    prefix = var.code_bucket_config != null ? var.code_bucket_config.prefix : "/"
  }
}

##################################################################
##########                  Image builder               ##########
##################################################################

# data "http" "sico_download" {
#   url = "https://checkpoint-api.hashicorp.com/v1/check/terraform"
# }

# resource "aws_s3_object" "file_upload" {
#   bucket = local.source_bucket.id
#   key    = "${local.source_bucket.prefix}${local.zip_name}"
#   source = "${path.module}/my_files.zip"
#   etag   = "${filemd5("${path.module}/my_files.zip")}"
# }

// removed image_build module as we now use inline Lambda packaging

##################################################################
##########                     Indexer                  ##########
##################################################################

# -- Lambda implementation for ECR image indexing --

# IAM role for Lambda execution
resource "aws_iam_role" "lambda_exec" {
  name = "${var.name}-lambda-exec"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach basic execution policy for CloudWatch logs
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Policy for ECR access
data "aws_iam_policy_document" "ecr_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:DescribeRepositories",
      "ecr:DescribeImages",
      "ecr:ListImages",
      "ecr:GetAuthorizationToken",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "lambda_ecr" {
  role   = aws_iam_role.lambda_exec.name
  policy = data.aws_iam_policy_document.ecr_policy.json
}

# Lambda function
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "indexer" {
  function_name    = var.name
  description      = "ECR image indexing lambda"
  runtime          = "python3.11"
  handler          = "lambda_function.lambda_handler"
  role             = aws_iam_role.lambda_exec.arn
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  timeout          = 900
  memory_size      = 1024
}

# EventBridge rule to trigger Lambda on ECR PUSH events
resource "aws_cloudwatch_event_rule" "ecr_trigger" {
  name = "${var.name}-ecr-trigger"
  event_pattern = var.event_filter_override != null ? var.event_filter_override : jsonencode({
    source        = ["aws.ecr"]
    "detail-type" = ["ECR Image Action"]
    detail = {
      "action-type" = ["PUSH"]
      "result"      = ["SUCCESS"]
    }
    region = [
      local.region
    ]
  })
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.indexer.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ecr_trigger.arn
}

resource "aws_cloudwatch_event_target" "ecr_trigger_target" {
  rule      = aws_cloudwatch_event_rule.ecr_trigger.name
  target_id = "${var.name}-lambda"
  arn       = aws_lambda_function.indexer.arn
}

# End of Lambda implementation
