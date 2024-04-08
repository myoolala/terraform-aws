module "secrets" {
  count  = var.secrets != null ? 1 : 0
  source = "../secrets"

  secrets         = var.secrets.secrets
  region          = var.secrets.region
  create_new_key  = true
  recovery_window = 0
}

resource "aws_cloudwatch_log_group" "logs" {
  name = var.name

  retention_in_days = var.log_retention
}

resource "aws_security_group" "service" {
  name   = "${var.name}-asg"
  vpc_id = var.network.vpc
}

resource "aws_security_group_rule" "ingresses" {
  count = length(var.network.ingresses)

  type                     = "ingress"
  from_port                = var.network.ingresses[count.index].from_port
  to_port                  = var.network.ingresses[count.index].to_port
  protocol                 = var.network.ingresses[count.index].protocol
  source_security_group_id = var.network.ingresses[count.index].source_sg
  cidr_blocks              = var.network.ingresses[count.index].cidr_blocks
  security_group_id        = aws_security_group.service.id
}

resource "aws_security_group_rule" "ingress" {
  count = length(var.lb.port_mappings)

  type                     = "ingress"
  from_port                = var.lb.port_mappings[count.index].forward_port
  to_port                  = var.lb.port_mappings[count.index].forward_port
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


resource "aws_launch_template" "image" {
  name_prefix   = var.name
  image_id      = var.ami
  instance_type = var.instance_type

  dynamic "block_device_mappings" {
    for_each = var.block_mappings

    content {
      device_name = block_device_mappings.value.name

      ebs {
        volume_size           = block_device_mappings.value.size
        delete_on_termination = block_device_mappings.value.delete_on_termination
        encrypted             = block_device_mappings.value.encrypted
        iops                  = block_device_mappings.value.iops
        kms_key_id            = block_device_mappings.value.kms_key
        snapshot_id           = block_device_mappings.value.snapshot_id
        volume_type           = block_device_mappings.value.type
      }
    }
  }

  # capacity_reservation_specification {
  #   capacity_reservation_preference = "open"
  # }

  # cpu_options {
  #   core_count       = 4
  #   threads_per_core = 2
  # }

  # credit_specification {
  #   cpu_credits = "standard"
  # }

  disable_api_stop        = var.protections.stop_protection
  disable_api_termination = var.protections.termination_protection

  ebs_optimized = var.ebs_optimized

  iam_instance_profile {
    name = aws_iam_instance_profile.server_role.name
  }

  instance_initiated_shutdown_behavior = "stop"

  # instance_market_options {
  #   market_type = "spot"
  # }

  key_name = var.key_name

  metadata_options {
    http_endpoint               = var.metadata.enabled
    http_tokens                 = var.metadata.tokens
    http_put_response_hop_limit = var.metadata.hop_limit
    instance_metadata_tags      = var.metadata.tags
  }

  monitoring {
    enabled = true
  }

  # network_interfaces {
  #   associate_public_ip_address = var.public
  # }

  vpc_security_group_ids = concat([aws_security_group.service.id], var.network.additional_sgs)

  tag_specifications {
    resource_type = "instance"

    tags = {
      "Key" : "Name",
      Value : var.name
    }
  }

  user_data = base64encode(join("\n", [
    "#!/bin/bash",
    var.user_data.pre_env,
    join("\n", [for k, v in var.env_vars : "export ${k}=${v}"]),
    var.user_data.post_env
    ]
  ))
}

resource "aws_autoscaling_group" "cluster" {
  desired_capacity          = var.capacity.initial
  max_size                  = var.capacity.max
  min_size                  = var.capacity.min
  vpc_zone_identifier       = var.network.subnets
  termination_policies      = var.config.termination_policies
  suspended_processes       = var.config.suspended_processes
  protect_from_scale_in     = var.protections.scale_in_protection
  service_linked_role_arn   = var.config.service_linked_role_arn
  max_instance_lifetime     = var.capacity.max_instance_lifetime
  health_check_type         = var.config.health_check_type
  health_check_grace_period = var.config.grace_period
  name                      = var.name

  launch_template {
    id      = aws_launch_template.image.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = var.name
    propagate_at_launch = true
  }

  lifecycle {
    ignore_changes = [
      desired_capacity
    ]
  }
  depends_on = [
    module.lb
  ]
}

module "lb" {
  source = "../load-balancer"

  vpc_id        = var.lb.vpc_id != null ? var.lb.vpc_id : var.network.vpc
  subnets       = var.lb.subnets != null ? var.lb.subnets : var.network.subnets
  ingress_cidrs = var.lb.ingress_cidrs
  # ingress_groups 
  egress_cidrs = ["0.0.0.0/0"]
  # egress_groups
  name                = var.name
  type                = var.lb.type
  internal            = var.lb.internal
  deletion_protection = var.lb.deletion_protection
  port_mappings       = [for i in var.lb.port_mappings : merge(i, { target_type : "instance" })]
}

resource "aws_autoscaling_attachment" "asg_lb" {
  count = length(module.lb.tg_arns)

  autoscaling_group_name = aws_autoscaling_group.cluster.id
  # elb                    = aws_elb.example.id
  lb_target_group_arn = module.lb.tg_arns[count.index]
}