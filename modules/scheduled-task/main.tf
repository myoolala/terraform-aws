data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

locals {
  secrets_to_create = [for secret in var.secrets : secret if secret.create]
  existing_secrets  = [for secret in var.secrets : { name = secret.env_name, valueFrom = secret.value } if secret.create == false]
  acct_id           = data.aws_caller_identity.current.account_id
  region            = data.aws_region.current.region
  partition         = data.aws_partition.current.partition
}

###########################################################################
###############                    Logging                  ###############
###########################################################################

module "logging_key" {
  count  = var.encrypt_logs.enabled && var.encrypt_logs.existing_key == null ? 1 : 0
  source = "../kms-key"

  description = "${var.service_name} logging key"
  permissions = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Cloudwatch access to encrypt and render
      {
        Sid = "LoggingServiceAccess"
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "logs.${local.region}.amazonaws.com"
        },
        "Action" : [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ],
        "Resource" : "*",
        "Condition" : {
          "ArnLike" : {
            "kms:EncryptionContext:aws:logs:arn" : "arn:${local.partition}:logs:${local.region}:${local.acct_id}:*"
          }
        }
      }
    ]
  })
}

resource "aws_cloudwatch_log_group" "logs" {
  name = var.service_name

  retention_in_days = var.log_retention
  kms_key_id        = var.encrypt_logs.enabled && var.encrypt_logs.existing_key == null ? module.logging_key[0].arn : var.encrypt_logs.existing_key
}

###########################################################################
###############                  Encryption                 ###############
###########################################################################

module "secrets" {
  source = "../secrets"

  secrets         = local.secrets_to_create
  create_new_key  = true
  recovery_window = 0
}

###########################################################################
###############                       ECS                   ###############
###########################################################################

resource "aws_ecs_cluster" "cluster" {
  count = var.cluster.create ? 1 : 0
  name  = var.cluster.name

  # @TODO: Add support for logging
}

resource "aws_ecr_repository" "service_repo" {
  count                = var.create_ecr_repo ? 1 : 0
  name                 = var.service_name
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }
}

module "image" {
  source = "../task-definition"

  name          = var.service_name
  service_name  = var.service_name
  image         = var.image_tag == null ? "${var.service_name}:latest" : var.image_tag
  log_group     = aws_cloudwatch_log_group.logs.name
  env_vars      = var.env_vars
  permissions   = var.permissions
  secrets       = concat(module.secrets.fargate_secrets, local.existing_secrets)
  secrets_keys  = [module.secrets.kms_key]
  port_mappings = []
  cpu           = var.cpu
  memory        = var.memory
  storage       = var.storage

  depends_on = [
    module.secrets
  ]
}

resource "aws_security_group" "service" {
  name   = "${var.service_name}-task"
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.service_name}-task"
  }
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.service.id
}

###########################################################################
###############                    Invoke                   ###############
###########################################################################

resource "aws_iam_role" "invoker" {
  name = "${var.service_name}-task-invoker"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "events.amazonaws.com"
        }
      },
    ]
  })
}

data "aws_iam_policy_document" "main" {
  statement {
    sid = "PassRole"

    effect = "Allow"
    actions = [
      "iam:PassRole",
    ]
    resources = ["*"]
  }

  statement {
    sid = "RequiredPerms"

    effect = "Allow"
    actions = [
      "ecs:RunTask",
    ]
    resources = [replace(module.image.task_definition_arn, "/:\\d+$/", ":*")]
  }
}

resource "aws_iam_role_policy" "main" {
  role   = aws_iam_role.invoker.name
  policy = data.aws_iam_policy_document.main.json
}

resource "aws_cloudwatch_event_rule" "schedule_trigger" {
  name                = "${var.service_name}-backup-trigger"
  schedule_expression = var.trigger.schedule_expression
  event_pattern       = var.trigger.event_pattern
}

resource "aws_cloudwatch_event_target" "schedule_trigger" {
  target_id = "${var.service_name}-scheduled-event"
  arn       = var.cluster.create ? aws_ecs_cluster.cluster[0].arn : var.cluster.arn
  rule      = aws_cloudwatch_event_rule.schedule_trigger.name
  role_arn  = aws_iam_role.invoker.arn

  ecs_target {
    task_count          = 1
    task_definition_arn = module.image.task_definition_arn
    launch_type         = "FARGATE"

    network_configuration {
      subnets = var.service_subnets
      security_groups = [
        aws_security_group.service.id
      ]
      assign_public_ip = var.public
    }
  }

  input = var.input
}