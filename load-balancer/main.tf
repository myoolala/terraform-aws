locals {
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


resource "aws_lb" "ingress" {
  name                       = var.name
  internal                   = var.internal
  load_balancer_type         = var.type
  enable_deletion_protection = var.deletion_protection
  subnets                    = var.subnets
  security_groups            = var.type != "internal" ? [var.security_group != null ? var.security_group : aws_security_group.lb[0].id] : null

  tags = merge(var.tags, {})

  # access_logs {
  #   bucket = "somewhere_over_the_rainbow"
  # }
}

resource "aws_lb_target_group" "forwarder" {
  count = length(var.port_mappings)

  name        = "${var.name}-${var.port_mappings[count.index].forward_port}"
  port        = var.port_mappings[count.index].forward_port
  protocol    = var.port_mappings[count.index].tg_protocol
  vpc_id      = var.vpc_id
  target_type = var.port_mappings[count.index].target_type

  health_check {
    enabled             = var.port_mappings[count.index].health_check.enabled
    matcher             = var.port_mappings[count.index].health_check.matcher
    interval            = var.port_mappings[count.index].health_check.interval
    healthy_threshold   = var.port_mappings[count.index].health_check.healthy_threshold
    unhealthy_threshold = var.port_mappings[count.index].health_check.unhealthy_threshold
    protocol            = var.port_mappings[count.index].health_check.service_protocol
    path                = var.port_mappings[count.index].health_check.path
  }
}

resource "aws_lb_listener" "public_endpoint" {
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