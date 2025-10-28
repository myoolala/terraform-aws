locals {
  final_snapshot_prefix = var.final_snapshot_id != "" ? var.final_snapshot_id : "${var.name}-final-snapshot"
}

resource "null_resource" "snapshot_id_trigger" {
  count = var.final_snapshot_id != null ? 1 : 0

  triggers = {
    db_image = var.db_image
  }
}

resource "random_uuid" "snapshot" {
  count = var.final_snapshot_id != null ? 1 : 0

  lifecycle {
    replace_triggered_by = [
      null_resource.snapshot_id_trigger
    ]
  }
}

locals {
  final_snapshot_id = var.final_snapshot_id != null ? "${local.final_snapshot_prefix}-${random_uuid.snapshot.result}" : null
  create_new_sg     = length(var.vpc_config.egress_cidr_whitelist) + length(var.vpc_config.egress_sg_whitelist) + length(var.vpc_config.ingress_cidr_whitelist) + length(var.vpc_config.ingress_sg_whitelist) > 0
}

module "rds_sg" {
  count  = local.create_new_sg ? 1 : 0
  source = "../security-group"

  name   = "${var.name}-rds-access"
  vpc_id = var.vpc_config.vpc_id
  # Do the rest of the whitelists
}

resource "aws_db_subnet_group" "subnets" {
  name       = var.name
  subnet_ids = var.vpc_config.subnets
  tags = {
    Name = "${var.name}"
  }
}

resource "aws_db_parameter_group" "params" {
  name   = "${var.pg_name != null ? var.pg_name : var.name}${var.param_group_suffix}"
  family = var.param_group_family

  dynamic "parameter" {
    for_each = var.parameters

    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Make a lambda to turn off rds 
resource "aws_db_instance" "db" {
  identifier                  = var.name
  allocated_storage           = var.allocated_storage
  max_allocated_storage       = var.max_allocated_storage
  engine                      = var.engine
  engine_version              = var.engine_version
  instance_class              = var.instance_class
  ca_cert_identifier          = var.ca
  username                    = var.admin_uname
  password                    = var.admin_default_password
  parameter_group_name        = aws_db_parameter_group.params.id
  option_group_name           = var.options_group_name
  snapshot_identifier         = var.db_image
  maintenance_window          = var.maintenance_window
  backup_window               = var.rds_backup_window
  db_name                     = var.db_name
  storage_encrypted           = var.storage_encrypted
  multi_az                    = var.multi_az
  auto_minor_version_upgrade  = var.auto_minor_version_upgrade
  allow_major_version_upgrade = var.allow_major_version_upgrade
  skip_final_snapshot         = false
  network_type                = var.network_type
  storage_type                = var.storage_type
  final_snapshot_identifier   = local.final_snapshot_id
  db_subnet_group_name        = aws_db_subnet_group.subnets.name
  publicly_accessible         = var.publicly_accessible
  backup_retention_period     = var.backup_retention_period
  vpc_security_group_ids = [
    aws_security_group.rds.id
  ]

  lifecycle {
    ignore_changes = [
      password
    ]
  }
}

resource "aws_cloudwatch_metric_alarm" "low_storage_space" {
  count = 0

  alarm_name          = "${var.name}-low-storage-space"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = "600"
  statistic           = "Minimum"
  threshold           = var.free_storage_space_threshold
  alarm_description   = "This metric monitors rds free storage space"
  alarm_actions       = var.alarm_arns
  ok_actions          = var.alarm_arns
  dimensions = {
    DBInstanceIdentifier = var.name
  }

  depends_on = [
    aws_db_instance.db
  ]
}