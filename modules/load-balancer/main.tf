data "aws_caller_identity" "current" {}

locals {
  acct = data.aws_caller_identity.current.account_id
}

resource "aws_security_group" "lb" {
  count = var.type != "network" ? 1 : 0

  name   = "${var.name}-lb"
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "cidr_ingresses" {
  count = var.type != "network" ? length(var.port_mappings) : 0

  type        = "ingress"
  from_port   = var.port_mappings[count.index].listen_port
  to_port     = var.port_mappings[count.index].listen_port
  protocol    = var.port_mappings[count.index].sg_protocol
  cidr_blocks = var.ingress_cidrs
  # source_security_group_id = var.ingresses[count.index].source_sg
  # ipv6_cidr_blocks  = var.ingresses[count.index].ipv6_cidrs
  security_group_id = aws_security_group.lb[0].id
}

# resource "aws_security_group_rule" "sg_ingresses" {
#     count = var.type != "network" ? length(var.ingresses): 0

#     type              = "ingress"
#     from_port         = var.ingresses[count.index].from_port
#     to_port           = var.ingresses[count.index].to_port
#     protocol          = var.ingresses[count.index].protocol
#     cidr_blocks       = var.egresses[count.index].cidrs
#     source_security_group_id = var.ingresses[count.index].source_sg
#     ipv6_cidr_blocks  = var.ingresses[count.index].ipv6_cidrs
#     security_group_id = aws_security_group.lb[0].id
# }

resource "aws_security_group_rule" "egresses" {
  count = var.type != "network" ? length(var.egress_cidrs) : 0

  type        = "egress"
  from_port   = -1
  to_port     = -1
  protocol    = "-1"
  cidr_blocks = var.egress_cidrs
  # source_security_group_id = var.egresses[count.index].source_sg
  # ipv6_cidr_blocks  = var.egresses[count.index].ipv6_cidrs
  security_group_id = aws_security_group.lb[0].id
}

locals {
  create_app_log_bucket = var.application_logs != null && var.application_logs.s3_bucket == null
}

module "application_logs_bucket" {
  source = "../s3-bucket"
  count  = local.create_app_log_bucket ? 1 : 0

  name = "${var.name}-application-log-${local.acct}"
}

resource "aws_s3_bucket_policy" "app_log_policy" {
  count = local.create_app_log_bucket ? 1 : 0

  bucket = module.application_logs_bucket[0].id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "logdelivery.elasticloadbalancing.amazonaws.com"
        },
        "Action" : "s3:PutObject",
        # When replace has a substring wrapped in forward slashes, auto converts the substring to a regex.
        # So // -> / needs //// -> /
        "Resource" : replace("${module.application_logs_bucket[0].arn}/${var.application_logs.prefix}/AWSLogs/${local.acct}/*", "////", "/")
      }
    ]
  })
}

# @TODO wat....
# @TODO What did this wat mean
resource "aws_lb" "ingress" {
  name                       = var.name
  internal                   = var.internal
  load_balancer_type         = var.type
  enable_deletion_protection = var.deletion_protection
  subnets                    = var.subnets
  idle_timeout               = var.idle_timeout
  security_groups            = var.type != "internal" && var.type != "network" ? [var.security_group != null ? var.security_group : aws_security_group.lb[0].id] : null

  tags = merge(var.tags, {})

  dynamic "access_logs" {
    for_each = var.application_logs != null ? [1] : []

    content {
      bucket  = local.create_app_log_bucket ? module.application_logs_bucket[0].id : var.application_logs.bucket
      enabled = var.application_logs.enabled
      prefix  = var.application_logs.prefix
    }
  }
}

resource "aws_lb_target_group" "forwarder" {
  count = length(var.port_mappings)

  name        = "${var.name}-${count.index}"
  port        = var.port_mappings[count.index].forward_port
  protocol    = var.port_mappings[count.index].tg_protocol
  vpc_id      = var.vpc_id
  target_type = var.port_mappings[count.index].target_type

  # Different options only allow us to specify particular fields so we need one for each
  dynamic "health_check" {
    for_each = var.port_mappings[count.index].target_type == "application" ? [1] : []

    content {
      enabled             = var.port_mappings[count.index].health_check.enabled
      matcher             = var.port_mappings[count.index].health_check.matcher
      interval            = var.port_mappings[count.index].health_check.interval
      healthy_threshold   = var.port_mappings[count.index].health_check.healthy_threshold
      unhealthy_threshold = var.port_mappings[count.index].health_check.unhealthy_threshold
      protocol            = var.port_mappings[count.index].health_check.service_protocol
      path                = var.port_mappings[count.index].health_check.path
    }
  }

  dynamic "health_check" {
    for_each = var.port_mappings[count.index].target_type == "network" ? [1] : []

    content {
      enabled             = var.port_mappings[count.index].health_check.enabled
      interval            = var.port_mappings[count.index].health_check.interval
      healthy_threshold   = var.port_mappings[count.index].health_check.healthy_threshold
      unhealthy_threshold = var.port_mappings[count.index].health_check.unhealthy_threshold
      protocol            = "TCP"
    }
  }
}

resource "aws_lb_listener" "this" {
  count = length(var.port_mappings)

  load_balancer_arn = aws_lb.ingress.arn
  port              = var.port_mappings[count.index].listen_port
  protocol          = var.port_mappings[count.index].lb_protocol
  ssl_policy        = var.port_mappings[count.index].lb_protocol == "HTTPS" ? "ELBSecurityPolicy-2016-08" : null
  certificate_arn   = var.port_mappings[count.index].lb_protocol == "HTTPS" ? var.port_mappings[count.index].cert : null

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.forwarder[count.index].arn
  }
}