data "aws_iam_policy_document" "container-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "task_role" {
  name = "${var.service_name}-task"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = "${data.aws_caller_identity.current.account_id}"
          }
        }
      },
    ]
  })

  tags = merge(var.tags, {
  })
}

resource "aws_iam_role_policy" "task_role" {
  # count = var.role == null ? 1 : 0

  role   = aws_iam_role.task_role.name
  name = "AppPermissions"
  policy = var.permissions
}

locals {
  task_role_managed_polciies = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ]
}

resource "aws_iam_role_policy_attachment" "task_role_managed_polciies" {
  count      = length(local.task_role_managed_polciies)

  role       = aws_iam_role.task_role.arn
  policy_arn = local.task_role_managed_polciies[count.index]
}


resource "aws_iam_role" "task_execution_role" {
  name = "${var.service_name}-task-exec"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

  tags = merge(var.tags, {
  })
}

data "aws_iam_policy_document" "task_exec_secret_perms" {
  count = length(var.secrets) + lenth(var.secrets_keys) > 0 ? 1 : 0

  dynamic "statement" {
    for_each = length(var.secrets) > 0 ? 1 : 0

    content {
      sid = "SecretsAccess"

      actions   = ["secretsmanager:GetSecretValue"]
      effect   = "Allow"
      resources = [for secret in var.secrets : secret.valueFrom]
    }
  }

  dynamic "statement" {
    for_each = length(var.secrets_keys) > 0 ? 1 : 0

    content {
      sid = "SecretsKmsAccess"

      actions = [
        "kms:Decrypt"
      ]
      effect   = "Allow"
      resources = var.secrets_keys
    }
  }
}

resource "aws_iam_role_policy" "task_exec_secret_perms" {
  # count = var.role == null ? 1 : 0

  role   = aws_iam_role.task_execution_role
  name = "SecretsPerms"
  policy = data.aws_iam_policy_document.task_exec_secret_perms.json
}

locals {
  exec_role_managed_polciies = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ]
}

resource "aws_iam_role_policy_attachment" "exec_role_managed_polciies" {
  count      = length(local.exec_role_managed_polciies)

  role       = aws_iam_role.task_execution_role.arn
  policy_arn = local.exec_role_managed_polciies[count.index]
}