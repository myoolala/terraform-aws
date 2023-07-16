resource "aws_launch_template" "image" {
  name_prefix   = var.template_prefix
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

  disable_api_stop        = var.enable_stop_protection
  disable_api_termination = var.enable_termination_protection

  ebs_optimized = var.ebs_optimized

  iam_instance_profile {
    # name = "test"
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

  network_interfaces {
    associate_public_ip_address = var.public
  }

  vpc_security_group_ids = var.additional_sgs

  tag_specifications {
    resource_type = "instance"

    tags = var.tags
  }

  # user_data = filebase64("${path.module}/example.sh")
}

resource "aws_autoscaling_group" "cluster" {
  #   availability_zones = ["us-east-1a"]
  desired_capacity          = var.desired_capacity
  max_size                  = var.max_size
  min_size                  = var.min_size
  vpc_zone_identifier       = var.subnets
  termination_policies      = var.termination_policies
  suspended_processes       = var.suspended_processes
  protect_from_scale_in     = var.protect_from_scale_in
  service_linked_role_arn   = var.service_linked_role_arn
  max_instance_lifetime     = var.max_instance_lifetime
  health_check_type         = var.health_check_type
  health_check_grace_period = var.grace_period
  name                      = var.name

  launch_template {
    id      = aws_launch_template.template_prefix.id
    version = "$Latest"
  }

  lifecycle {
    ignore_changes = [
      desired_capaicty
    ]
  }
}