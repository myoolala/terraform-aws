locals {
  final_snapshot_prefix = var.final_snapshot_id == null ? "${var.name}-final-snapshot" : (var.final_snapshot_id == "" ? "${var.name}-final-snapshot" : var.final_snapshot_id)
  # Multiple entries require an explicit selection; checked below.
  config_key               = var.selected_config != null ? var.selected_config : keys(var.configs)[0]
  config                   = var.configs[local.config_key]
  generate_password        = !var.manage_master_user_password && nonsensitive(var.password == null) && var.db_image == null
  create_connection_secret = !var.manage_master_user_password && (var.db_image == null || nonsensitive(var.password != null))
  admin_password           = var.manage_master_user_password ? null : (var.password != null ? var.password : (local.generate_password ? random_string.default_pw[0].result : null))
}

resource "null_resource" "snapshot_id_trigger" {
  count = var.skip_final_snapshot ? 0 : 1

  triggers = {
    db_image = var.db_image
    # @TODO: make a way to check if the db id has changed to make taints not a pain
    # db_id = aws_db_instance.db.id
  }
}

resource "random_uuid" "snapshot" {
  count = var.skip_final_snapshot ? 0 : 1

  lifecycle {
    replace_triggered_by = [
      null_resource.snapshot_id_trigger
    ]
  }
}

resource "random_string" "default_pw" {
  count   = local.generate_password ? 1 : 0
  length  = 16
  special = false # Set to true to include special characters
  numeric = true  # Set to true to include numbers
  upper   = true  # Set to true to include uppercase letters
  lower   = true  # Set to true to include lowercase letters
}

locals {
  final_snapshot_id = var.skip_final_snapshot ? null : "${local.final_snapshot_prefix}-${random_uuid.snapshot[0].result}"

  new_sg_ingress_rules = concat(length(var.vpc_config.ingress_cidr_whitelist) > 0 ? [{
    from_port   = var.port
    to_port     = var.port
    protocol    = "tcp"
    cidr_blocks = var.vpc_config.ingress_cidr_whitelist
    }] : [], [for i, v in var.vpc_config.ingress_sg_whitelist : {
    from_port                = var.port
    to_port                  = var.port
    protocol                 = "tcp"
    source_security_group_id = v
  }])

  new_sg_egress_rules = concat(length(var.vpc_config.egress_cidr_whitelist) > 0 ? [{
    from_port   = var.port
    to_port     = var.port
    protocol    = "tcp"
    cidr_blocks = var.vpc_config.egress_cidr_whitelist
    }] : [], [for i, v in var.vpc_config.egress_sg_whitelist : {
    from_port                = var.port
    to_port                  = var.port
    protocol                 = "tcp"
    source_security_group_id = v
  }])
}

module "rds_sg" {
  count  = var.create_sg ? 1 : 0
  source = "../security-group"

  name      = "${var.name}-rds-access"
  vpc_id    = var.vpc_config.vpc_id
  ingresses = local.new_sg_ingress_rules
  egresses  = local.new_sg_egress_rules
}

resource "aws_db_subnet_group" "subnets" {
  name       = var.name
  subnet_ids = var.vpc_config.subnets
  tags       = merge(var.tags, { Name = var.name })
}

resource "aws_db_parameter_group" "params" {
  for_each = var.configs
  name     = "${each.value.parameter_group_name != null ? each.value.parameter_group_name : "${substr(var.name, 0, 100)}-${substr(sha256("${each.key}:${each.value.parameter_group_family}"), 0, 12)}"}${each.value.parameter_group_suffix}"
  family   = each.value.parameter_group_family
  tags     = var.tags

  dynamic "parameter" {
    for_each = each.value.parameters

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

resource "aws_db_instance" "db" {
  identifier                      = var.name
  port                            = var.port
  kms_key_id                      = var.kms_key_id
  license_model                   = var.license_model
  deletion_protection             = var.deletion_protection
  copy_tags_to_snapshot           = var.copy_tags_to_snapshot
  delete_automated_backups        = var.delete_automated_backups
  apply_immediately               = var.apply_immediately
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  monitoring_interval             = var.monitoring_interval
  monitoring_role_arn             = var.monitoring_interval == 0 ? null : var.monitoring_role_arn
  manage_master_user_password     = var.manage_master_user_password ? true : null
  master_user_secret_kms_key_id   = var.manage_master_user_password ? var.master_user_secret_kms_key_id : null
  tags                            = var.tags
  allocated_storage               = var.allocated_storage
  max_allocated_storage           = var.max_allocated_storage
  engine                          = local.config.engine
  engine_version                  = local.config.engine_version
  instance_class                  = var.instance_class
  ca_cert_identifier              = var.ca
  username                        = var.admin_uname
  password                        = local.admin_password
  parameter_group_name            = aws_db_parameter_group.params[local.config_key].id
  option_group_name               = local.config.option_group_name
  snapshot_identifier             = var.db_image
  maintenance_window              = var.maintenance_window
  backup_window                   = var.rds_backup_window
  db_name                         = startswith(local.config.engine, "sqlserver-") ? null : var.db_name
  storage_encrypted               = var.storage_encrypted
  multi_az                        = var.multi_az
  auto_minor_version_upgrade      = var.auto_minor_version_upgrade
  allow_major_version_upgrade     = var.allow_major_version_upgrade
  skip_final_snapshot             = var.skip_final_snapshot
  network_type                    = var.network_type
  storage_type                    = var.storage_type
  final_snapshot_identifier       = local.final_snapshot_id
  db_subnet_group_name            = aws_db_subnet_group.subnets.name
  publicly_accessible             = var.publicly_accessible
  backup_retention_period         = var.backup_retention_period
  vpc_security_group_ids          = concat(var.vpc_config.sg_ids, module.rds_sg[*].id)

  lifecycle {
    precondition {
      condition     = var.selected_config != null || length(var.configs) == 1
      error_message = "selected_config must be explicit when configs contains multiple entries."
    }
    precondition {
      condition     = !(local.config.engine == "sqlserver-ex" && var.multi_az)
      error_message = "SQL Server Express does not support Multi-AZ."
    }
    precondition {
      condition     = !var.manage_master_user_password || var.password == null
      error_message = "password conflicts with RDS-managed credentials."
    }
    precondition {
      condition     = var.master_user_secret_kms_key_id == null || var.manage_master_user_password
      error_message = "A managed-secret KMS key requires managed credentials."
    }
    precondition {
      condition     = var.kms_key_id == null || var.storage_encrypted
      error_message = "A database KMS key requires storage_encrypted=true."
    }
    precondition {
      condition     = contains([0, 1, 5, 10, 15, 30, 60], var.monitoring_interval) && (var.monitoring_interval == 0 || var.monitoring_role_arn != null)
      error_message = "Enhanced Monitoring requires a supported interval and IAM role."
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "low_storage_space" {
  count = var.free_storage_space_threshold != null ? 1 : 0

  tags                = var.tags
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

locals {
  admin_sm_name = "${var.name}-db-login"
}

module "admin_connection_info" {
  count  = local.create_connection_secret ? 1 : 0
  source = "../secrets"

  secrets = [
    {
      name = local.admin_sm_name
      value = jsonencode({
        username            = var.admin_uname
        password            = local.admin_password
        host                = aws_db_instance.db.address
        port                = aws_db_instance.db.port
        dbname              = aws_db_instance.db.db_name
        engine              = local.config.engine
        dbClusterIdentifier = null
      })
    }
  ]
  create_new_key  = false
  recovery_window = var.secret_recovery_window_in_days
}