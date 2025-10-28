resource "aws_cloudwatch_log_group" "logs" {
  name = "/aws/lambda/${aws_lambda_function.function.function_name}"

  retention_in_days = var.log_retention
}

resource "aws_iam_role" "lambda_exec" {
  count = var.role == null ? 1 : 0
  name  = var.function_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

data "aws_iam_policy_document" "perms" {
  count = var.role == null ? 1 : 0

  statement {
    sid = "LogAccess"

    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }


  dynamic "statement" {
    for_each = var.vpc_config != null ? [1] : []

    content {
      sid = "VpcAccess"

      effect = "Allow"
      actions = [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface"
      ]
      resources = ["*"]
    }
  }

  dynamic "statement" {
    for_each = length(var.secrets.arns) > 0 ? [1] : []

    content {
      sid = "SecretsAccess"

      effect = "Allow"
      actions = [
        "secretsmanager:GetSecretValue",
      ]
      resources = [var.secrets.arns]
    }
  }

  dynamic "statement" {
    for_each = length(var.secrets.arns) > 0 && length(var.secrets.kms_keys) > 0 ? [1] : []

    content {
      sid = "SecretsKmsAccess"

      effect = "Allow"
      actions = [
        "kms:Decrypt",
      ]
      resources = [var.secrets.kms_keys]
    }
  }
}

resource "aws_iam_role_policy" "perms" {
  count = var.role == null ? 1 : 0

  role   = aws_iam_role.lambda_exec[0].name
  policy = data.aws_iam_policy_document.perms[0].json
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  count      = var.role != null ? 1 : 0
  role       = aws_iam_role.lambda_exec[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "function" {
  function_name = var.function_name

  filename  = var.file_path
  s3_bucket = var.bucket
  s3_key    = var.key

  runtime = var.runtime
  handler = var.handler
  timeout = var.timeout

  role = var.role != null ? var.role : aws_iam_role.lambda_exec[0].arn

  dynamic "environment" {
    for_each = var.environment_vars != null ? [1] : []
    content {
      variables = var.environment_vars
    }
  }

  dynamic "vpc_config" {
    for_each = var.vpc_config != null ? [1] : []
    content {
      subnet_ids         = var.vpc_config.subnet_ids
      security_group_ids = var.vpc_config.security_group_ids
    }
  }

  depends_on = [
    aws_iam_role.lambda_exec,
    aws_iam_role_policy.perms,
    aws_iam_role_policy_attachment.lambda_policy
  ]
}