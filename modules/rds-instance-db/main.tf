locals {
  final_snapshot_prefix = var.final_snapshot_id != "" ? var.final_snapshot_id : "${var.name}-final-snapshot"
  # Basically, if there is no key provided, assume there is only 1 config and use that
  config_key = var.selected_config != null ? var.selected_config : keys(var.configs)[0]
  config = var.configs[local.config_key]
}

resource "null_resource" "snapshot_id_trigger" {
  count = var.final_snapshot_id != null ? 1 : 0

  triggers = {
    db_image = var.db_image
    # @TODO: make a way to check if the db id has changed to make taints not a pain
    # db_id = aws_db_instance.db.id
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

resource "random_string" "default_pw" {
  length  = 16
  special = false # Set to true to include special characters
  numeric = true # Set to true to include numbers
  upper   = true # Set to true to include uppercase letters
  lower   = true  # Set to true to include lowercase letters
}

locals {
  final_snapshot_id = var.final_snapshot_id != null ? "${local.final_snapshot_prefix}-${random_uuid.snapshot[0].result}" : null

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
  tags = {
    Name = "${var.name}"
  }
}

resource "aws_db_parameter_group" "params" {
  name   = "${local.config.pg_name != null ? local.config.pg_name : var.name}${local.config.pg_suffix}"
  family = local.config.pg_family

  dynamic "parameter" {
    for_each = local.config.parameters

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
  identifier                  = var.name
  allocated_storage           = var.allocated_storage
  max_allocated_storage       = var.max_allocated_storage
  engine                      = local.config.engine
  engine_version              = local.config.engine_version
  instance_class              = var.instance_class
  ca_cert_identifier          = var.ca
  username                    = var.admin_uname
  password                    = random_string.default_pw.result
  parameter_group_name        = aws_db_parameter_group.params.id
  option_group_name           = local.config.og_name
  snapshot_identifier         = var.db_image
  maintenance_window          = var.maintenance_window
  backup_window               = var.rds_backup_window
  db_name                     = var.db_name
  storage_encrypted           = var.storage_encrypted
  multi_az                    = var.multi_az
  auto_minor_version_upgrade  = var.auto_minor_version_upgrade
  allow_major_version_upgrade = var.allow_major_version_upgrade
  skip_final_snapshot         = var.skip_final_snapshot
  network_type                = var.network_type
  storage_type                = var.storage_type
  final_snapshot_identifier   = local.final_snapshot_id
  db_subnet_group_name        = aws_db_subnet_group.subnets.name
  publicly_accessible         = var.publicly_accessible
  backup_retention_period     = var.backup_retention_period
  vpc_security_group_ids      = concat(var.vpc_config.sg_ids, module.rds_sg[*].id)

  lifecycle {
    ignore_changes = [
      password
    ]
  }
}

resource "aws_cloudwatch_metric_alarm" "low_storage_space" {
  count = var.free_storage_space_threshold != null ? 1 : 0

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

module "admin_connection_info" {
  source = "../secrets"

  secrets = [
    {
      name = "${var.name}-login"
      value = jsonencode({
        username = var.admin_uname
        password = random_string.default_pw.result
        host = aws_db_instance.db.address
        port = var.port
        dbame = var.db_name
        engine = local.config.engine
        dbClusterIdentifier = null
      })
    }
  ]
  # @TODO: make this a config to pass in
  create_new_key = false
  recovery_window = 0
}