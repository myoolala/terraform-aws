resource "aws_dynamodb_table" "this" {
  name           = var.name
  billing_mode   = var.billing_mode
  read_capacity  = var.read_capacity
  write_capacity = var.write_capacity
  hash_key       = var.hash_key
  range_key      = var.range_key

  dynamic "attribute" {
    for_each = var.attributes

    content {
      name = attribute.name
      type = attribute.type
    }
  }

  server_side_encryption {
    enabled     = var.encryption.enabled
    kms_key_arn = var.encryption.kms_key_arn
  }

  point_in_time_recovery {
    enabled                 = var.backups.enabled
    recovery_period_in_days = var.backups.recovery_period_in_days
  }

  dynamic "ttl" {
    for_each = var.ttl_field != null ? [1] : []

    content {
      attribute_name = var.ttl_field
      enabled        = true
    }
  }

  dynamic "global_secondary_index" {
    for_each = var.gsis

    content {
      name               = global_secondary_index.value.name
      hash_key           = global_secondary_index.value.hash_key
      range_key          = global_secondary_index.value.range_key
      write_capacity     = global_secondary_index.value.write_capacity
      read_capacity      = global_secondary_index.value.read_capacity
      projection_type    = global_secondary_index.value.projection_type
      non_key_attributes = global_secondary_index.value.non_key_attributes
    }
  }

  dynamic "local_secondary_index" {
    for_each = var.lsis

    content {
      name               = local_secondary_index.value.name
      range_key          = local_secondary_index.value.range_key
      non_key_attributes = local_secondary_index.value.non_key_attributes
      projection_type    = local_secondary_index.value.projection_type
    }
  }

  dynamic "replica" {
    for_each = var.replica_regions

    content {
      region_name = replica.value
    }
  }

  tags = var.tags
}