data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  acct          = data.aws_caller_identity.current.account_id
  region        = data.aws_region.current.region
  database_name = coalesce(var.database_name, replace("${var.name}_alb_logs", "-", "_"))

  logs_location = "${trim("s3://${var.alb_logs_bucket}/${var.alb_logs_prefix}", "/")}/"

  create_results_bucket = var.athena_results_bucket == null
}

module "results_bucket" {
  count  = local.create_results_bucket ? 1 : 0
  source = "../s3-bucket"

  name = "${var.name}-results-${local.acct}"
}

locals {
  results_bucket          = local.create_results_bucket ? module.results_bucket[0].id : var.athena_results_bucket
  athena_results_location = "s3://${local.results_bucket}/athena-results/${var.name}/"
}

resource "aws_glue_catalog_database" "this" {
  name = local.database_name
}

resource "aws_glue_catalog_table" "alb_access_logs" {
  name          = var.table_name
  database_name = aws_glue_catalog_database.this.name
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    EXTERNAL                 = "TRUE"
    "skip.header.line.count" = "0"
    "projection.enabled"     = "true"

    # ALB logs are commonly partitioned by account/region/year/month/day.
    "projection.account.type" = "injected"
    "projection.region.type"  = "injected"

    "projection.year.type"    = "integer"
    "projection.year.range"   = "2020,2050"
    "projection.month.type"   = "integer"
    "projection.month.range"  = "1,12"
    "projection.month.digits" = "2"
    "projection.day.type"     = "integer"
    "projection.day.range"    = "1,31"
    "projection.day.digits"   = "2"

    "storage.location.template" = "${local.logs_location}AWSLogs/$${account}/elasticloadbalancing/$${region}/$${year}/$${month}/$${day}/"
  }

  dynamic "partition_keys" {
    for_each = var.partition_keys

    content {
      name = partition_keys.key
      type = partition_keys.value.type
    }
  }

  storage_descriptor {
    location      = local.logs_location
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.serde2.RegexSerDe"

      parameters = {
        "serialization.format" = "1"

        "input.regex" = var.ser_de_info_regex
      }
    }

    dynamic "columns" {
      for_each = var.columns

      content {
        name = columns.key
        type = columns.value.type
      }
    }

    dynamic "columns" {
      for_each = var.additional_columns

      content {
        name = columns.key
        type = columns.value.type
      }
    }
  }
}

resource "aws_s3_object" "athena_results_prefix" {
  bucket  = local.results_bucket
  key     = "athena-results/${var.name}/"
  content = ""
}

resource "aws_athena_workgroup" "this" {
  name = var.name

  configuration {
    enforce_workgroup_configuration = true

    result_configuration {
      output_location = local.athena_results_location
    }
  }
}