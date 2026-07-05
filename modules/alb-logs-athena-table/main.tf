data "aws_caller_identity" "current" {}

locals {
  database_name = coalesce(var.database_name, replace("${var.name}_alb_logs", "-", "_"))

  logs_location = "s3://${var.alb_logs_bucket}/${trim(var.alb_logs_prefix, "/")}/"

  create_results_bucket = var.athena_results_bucket == null
  acct      = data.aws_caller_identity.current.account_id
}

module "results_bucket" {
  count = local.create_results_bucket ? 1 : 0
  source = "../s3-bucket"

  name = "${var.name}-results-${local.acct}"
}

locals {
  results_bucket = local.create_results_bucket ? module.results_bucket[0].id : var.athena_results_bucket
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

  partition_keys {
    name = "account"
    type = "string"
  }

  partition_keys {
    name = "region"
    type = "string"
  }

  partition_keys {
    name = "year"
    type = "string"
  }

  partition_keys {
    name = "month"
    type = "string"
  }

  partition_keys {
    name = "day"
    type = "string"
  }

  storage_descriptor {
    location      = local.logs_location
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.serde2.RegexSerDe"

      parameters = {
        "serialization.format" = "1"

        "input.regex" = "([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*):([0-9]*) ([^ ]*)[:-]([0-9]*) ([-.0-9]*) ([-.0-9]*) ([-.0-9]*) (|[-0-9]*) (|[-0-9]*) ([0-9]*) ([0-9]*) \"([^ ]*) (.*) (- |[^ ]*)\" \"([^\"]*)\" ([A-Z0-9-_]+) ([A-Za-z0-9.-]*) ([^ ]*) \"([^\"]*)\" \"([^\"]*)\" \"([^\"]*)\" ([-.0-9]*) ([^ ]*) \"([^\"]*)\" \"([^\"]*)\" \"([^ ]*)\" \"([^\\s]+?)\" \"([^\\s]+)\" \"([^ ]*)\" \"([^ ]*)\" ?([^ ]*)?"
      }
    }

    columns {
      name = "type"
      type = "string"
    }

    columns {
      name = "time"
      type = "string"
    }

    columns {
      name = "elb"
      type = "string"
    }

    columns {
      name = "client_ip"
      type = "string"
    }

    columns {
      name = "client_port"
      type = "int"
    }

    columns {
      name = "target_ip"
      type = "string"
    }

    columns {
      name = "target_port"
      type = "int"
    }

    columns {
      name = "request_processing_time"
      type = "double"
    }

    columns {
      name = "target_processing_time"
      type = "double"
    }

    columns {
      name = "response_processing_time"
      type = "double"
    }

    columns {
      name = "elb_status_code"
      type = "int"
    }

    columns {
      name = "target_status_code"
      type = "string"
    }

    columns {
      name = "received_bytes"
      type = "bigint"
    }

    columns {
      name = "sent_bytes"
      type = "bigint"
    }

    columns {
      name = "request_verb"
      type = "string"
    }

    columns {
      name = "request_url"
      type = "string"
    }

    columns {
      name = "request_proto"
      type = "string"
    }

    columns {
      name = "user_agent"
      type = "string"
    }

    columns {
      name = "ssl_cipher"
      type = "string"
    }

    columns {
      name = "ssl_protocol"
      type = "string"
    }

    columns {
      name = "target_group_arn"
      type = "string"
    }

    columns {
      name = "trace_id"
      type = "string"
    }

    columns {
      name = "domain_name"
      type = "string"
    }

    columns {
      name = "chosen_cert_arn"
      type = "string"
    }

    columns {
      name = "matched_rule_priority"
      type = "string"
    }

    columns {
      name = "request_creation_time"
      type = "string"
    }

    columns {
      name = "actions_executed"
      type = "string"
    }

    columns {
      name = "redirect_url"
      type = "string"
    }

    columns {
      name = "lambda_error_reason"
      type = "string"
    }

    columns {
      name = "target_port_list"
      type = "string"
    }

    columns {
      name = "target_status_code_list"
      type = "string"
    }

    columns {
      name = "classification"
      type = "string"
    }

    columns {
      name = "classification_reason"
      type = "string"
    }

    columns {
      name = "conn_trace_id"
      type = "string"
    }
  }
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