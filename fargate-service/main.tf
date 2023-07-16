module "secrets" {
  source = "../secrets"

  secrets         = var.secrets
  region          = var.region
  create_new_key  = true
  recovery_window = 0
}

resource "aws_ecs_cluster" "cluster" {
  count = var.cluster.create ? 1 : 0
  name  = var.cluster.name

  # @TODO: Add support for logging
}

data "aws_ecs_cluster" "cluster" {
  cluster_name = var.cluster.name

  depends_on = [
    aws_ecs_cluster.cluster
  ]
}

resource "aws_ecr_repository" "service_repo" {
  count                = var.ecr.create ? 1 : 0
  name                 = var.service_name
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = var.ecr.scan_on_push
  }
}

resource "aws_cloudwatch_log_group" "logs" {
  name = var.service_name

  retention_in_days = var.log_retention
}

module "image" {
  source = "../task-definition"

  name         = var.service_name
  service_name = var.service_name
  image        = var.image_tag == null ? "${var.service_name}:latest" : var.image_tag
  log_group    = aws_cloudwatch_log_group.logs.name
  env_vars     = var.env_vars
  secrets      = module.secrets.fargate_secrets
  secrets_keys = module.secrets.kms_key != null ? [module.secrets.kms_key] : []
  port_mappings = [for i in var.lb.port_mappings : {
    containerPort = i.forward_port
    hostPort      = i.forward_port
  }]

  depends_on = [
    module.secrets
  ]
}

resource "aws_security_group" "service" {
  name   = "${var.service_name}-fargate"
  vpc_id = var.network.vpc_id
}

resource "aws_security_group_rule" "ingress" {
  count = length(var.lb.port_mappings)

  type                     = "ingress"
  from_port                = var.lb.port_mappings[count.index].listen_port
  to_port                  = var.lb.port_mappings[count.index].listen_port
  protocol                 = var.lb.port_mappings[count.index].sg_protocol
  source_security_group_id = module.lb.sg_id
  security_group_id        = aws_security_group.service.id
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.service.id
}

resource "aws_ecs_service" "app" {
  name            = var.service_name
  cluster         = var.cluster.create ? aws_ecs_cluster.cluster[0].arn : data.aws_ecs_cluster.cluster.arn
  task_definition = module.image.task_definition_arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets = var.network.subnets
    security_groups = [
      aws_security_group.service.id
    ]
    // Required if deploying to a public subnet
    assign_public_ip = true
  }


  #   ordered_placement_strategy {
  #     type  = "binpack"
  #     field = "cpu"
  #   }

  dynamic "load_balancer" {
    for_each = var.lb.port_mappings

    content {
      target_group_arn = module.lb.tg_arns[load_balancer.key]
      container_name   = var.service_name
      container_port   = load_balancer.value.forward_port
    }
  }

  #   placement_constraints {
  #     type       = "memberOf"
  #     expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
  #   }

  # We don't want to mess with the autoscaling
  lifecycle {
    ignore_changes = [
      desired_count
    ]
  }

  depends_on = [
    module.image,
    module.lb
  ]
}

module "lb" {
  source = "../load-balancer"

  vpc_id        = var.lb.vpc_id != null ? var.lb.vpc_id : var.network.vpc_id
  subnets       = var.lb.subnets != null ? var.lb.subnets : var.network.subnets
  ingress_cidrs = var.lb.ingress_cidrs
  # ingress_groups 
  egress_cidrs = ["0.0.0.0/0"]
  # egress_groups
  name                = var.service_name
  type                = var.lb.type
  internal            = var.lb.internal
  deletion_protection = var.lb.deletion_protection
  port_mappings       = var.lb.port_mappings
}