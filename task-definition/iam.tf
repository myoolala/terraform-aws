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

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ]

  inline_policy {
    name   = "AppPermissions"
    policy = var.permissions
  }

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


resource "aws_iam_role" "task_execution_role" {
  name = "${var.service_name}-task-exec"
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ]

  inline_policy {
    name = "SecretsAccess"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = concat([
        {
          Action   = "secretsmanager:GetSecretValue"
          Effect   = "Allow"
          Sid      = ""
          Resource = [for secret in var.secrets : secret.valueFrom]
        }], length(var.secrets_keys) == 0 ? [] : [
        {
          Action = [
            "kms:Decrypt"
          ]
          Effect   = "Allow"
          Sid      = ""
          Resource = var.secrets_keys
        }
      ])
    })
  }

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