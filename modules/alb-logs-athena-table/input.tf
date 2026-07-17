###########################################################################
###############                   Required                  ###############
###########################################################################

variable "name" {
  description = "Name prefix for Athena and Glue resources."
  type        = string
}

variable "alb_logs_bucket" {
  description = "S3 bucket containing ALB access logs."
  type        = string
}

variable "alb_logs_prefix" {
  description = "S3 prefix where ALB access logs are stored."
  type        = string
}

###########################################################################
###############                   Optional                  ###############
###########################################################################

variable "database_name" {
  description = "Glue database name."
  type        = string
  default     = null
}

variable "table_name" {
  description = "Glue table name."
  type        = string
  default     = "alb_access_logs"
}

variable "athena_results_bucket" {
  description = "S3 bucket for Athena query results. Leave null to create a new bucket"
  type        = string
  default     = null
}
variable "ser_de_info_regex" {
  description = "Primary regex used to parse the logs. This would probably change with a WAF attached to the ALB"
  type        = string
  default     = "([^ ]+) ([^ ]+) ([^ ]+) ([^: ]+):([0-9]+) ([^ ]+)(?::([0-9]+))? ([^ ]+) ([^ ]+) ([^ ]+) ([^ ]+) ([^ ]+) ([^ ]+) ([^ ]+) \"([^ ]+) ([^\"]*) ([^ ]+)\" \"([^\"]*)\" ([^ ]+) ([^ ]+) ([^ ]+) \"([^\"]*)\" \"([^\"]*)\" \"([^\"]*)\" ([^ ]+) ([^ ]+) \"([^\"]*)\" \"([^\"]*)\" \"([^\"]*)\" \"([^\"]*)\" \"([^\"]*)\" \"([^\"]*)\" \"([^\"]*)\" ([^ ]+) \"([^\"]*)\" \"([^\"]*)\" \"([^\"]*)\""
}

variable "partition_keys" {
  type = list(object({
    name = string
    type = optional(string, "string")
  }))
  description = "Parition keys to attach to the table"
  default = [
    { name = "account" },
    { name = "region" },
    { name = "year" },
    { name = "month" },
    { name = "day" },
  ]
}

variable "columns" {
  type = map(object({
    type = optional(string, "string")
  }))
  description = "Columns in order to match to the regex"
  default = [
    { name = "type", },
    { name = "time", },
    { name = "elb", },
    { name = "client_ip", },
    { name = "client_port", type = "int" },
    { name = "target_ip", },
    { name = "target_port", },
    { name = "request_processing_time", type = "double" },
    { name = "target_processing_time", type = "double" },
    { name = "response_processing_time", type = "double" },
    { name = "elb_status_code", type = "int" },
    { name = "target_status_code", },
    { name = "received_bytes", type = "bigint" },
    { name = "sent_bytes", type = "bigint" },
    { name = "request_verb", },
    { name = "request_url", },
    { name = "request_proto", },
    { name = "user_agent", },
    { name = "ssl_cipher", },
    { name = "ssl_protocol", },
    { name = "target_group_arn", },
    { name = "trace_id", },
    { name = "domain_name", },
    { name = "chosen_cert_arn", },
    { name = "matched_rule_priority", },
    { name = "request_creation_time", },
    { name = "actions_executed", },
    { name = "redirect_url", },
    { name = "lambda_error_reason", },
    { name = "target_port_list", },
    { name = "target_status_code_list", },
    { name = "classification", },
    { name = "classification_reason", },
    { name = "conn_trace_id", },
    { name = "transformed_host", },
    { name = "transformed_uri", },
    { name = "request_transform_status", }
  ]
}

variable "additional_columns" {
  type = list(object({
    name = string
    type = optional(string, "string")
  }))
  description = "Additional columns in order to match to the regex at the end of the main columns. Intention is to make adding columns easier"
  default     = {}
}