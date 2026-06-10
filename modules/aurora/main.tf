# modules/aurora/main.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6"
    }
  }
}

resource "random_id" "final_snapshot" {
  byte_length = 4

  # Change this list to match fields that should cause a new final snapshot ID.
  keepers = {
    cluster_identifier = var.cluster_identifier
    engine             = var.engine
    engine_version     = var.engine_version
    database_name      = var.database_name
    master_username    = var.master_username
    subnet_group       = var.db_subnet_group_name
    kms_key_id         = coalesce(var.kms_key_id, "")
    instances          = jsonencode(var.instances)
    snapshot_seed      = var.final_snapshot_seed
  }
}

locals {
  final_snapshot_identifier = lower(
    "${var.cluster_identifier}-final-${random_id.final_snapshot.hex}"
  )
}

resource "aws_rds_cluster" "this" {
  cluster_identifier = var.cluster_identifier

  engine         = var.engine
  engine_version = var.engine_version

  database_name   = var.database_name
  master_username = var.master_username
  master_password = var.master_password

  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = var.vpc_security_group_ids

  port = var.port

  storage_encrypted = var.storage_encrypted
  kms_key_id        = var.kms_key_id

  backup_retention_period = var.backup_retention_period
  preferred_backup_window = var.preferred_backup_window

  skip_final_snapshot       = false
  final_snapshot_identifier = local.final_snapshot_identifier

  iam_database_authentication_enabled = var.iam_database_authentication_enabled

  apply_immediately = var.apply_immediately

  tags = var.tags
}

resource "aws_rds_cluster_instance" "this" {
  for_each = var.instances

  identifier         = each.value.identifier
  cluster_identifier = aws_rds_cluster.this.id

  engine         = aws_rds_cluster.this.engine
  engine_version = aws_rds_cluster.this.engine_version

  instance_class = each.value.instance_class

  db_subnet_group_name = var.db_subnet_group_name

  publicly_accessible = lookup(each.value, "publicly_accessible", false)
  promotion_tier      = lookup(each.value, "promotion_tier", 1)
  availability_zone   = lookup(each.value, "availability_zone", null)

  apply_immediately = var.apply_immediately

  tags = merge(var.tags, lookup(each.value, "tags", {}))
}