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
  type = string
  default = "([^ ]+) ([^ ]+) ([^ ]+) ([^: ]+):([0-9]+) ([^ ]+)(?::([0-9]+))? ([^ ]+) ([^ ]+) ([^ ]+) ([^ ]+) ([^ ]+) ([^ ]+) ([^ ]+) \"([^ ]+) ([^\"]*) ([^ ]+)\" \"([^\"]*)\" ([^ ]+) ([^ ]+) ([^ ]+) \"([^\"]*)\" \"([^\"]*)\" \"([^\"]*)\" ([^ ]+) ([^ ]+) \"([^\"]*)\" \"([^\"]*)\" \"([^\"]*)\" \"([^\"]*)\" \"([^\"]*)\" \"([^\"]*)\" \"([^\"]*)\" ([^ ]+) \"([^\"]*)\" \"([^\"]*)\" \"([^\"]*)\""
}

variable "partition_keys" {
  type = map(object({
    type = optional(string, "string")
  }))
  description = "Parition keys to attach to the table"
  default = {
    account = {},
    region = {},
    year = {},
    month = {},
    day = {},
  }
}

variable "columns" {
  type = map(object({
    type = optional(string, "string")
  }))
  description = "Columns in order to match to the regex"
  default = {
    type = {},
    time = {},
    elb = {},
    client_ip = {},
    client_port = { type = "int" },
    target_ip = {},
    target_port = {},
    request_processing_time = { type = "double" },
    target_processing_time = { type = "double" },
    response_processing_time = { type = "double" },
    elb_status_code = { type = "int" },
    target_status_code = {},
    received_bytes = { type = "bigint" },
    sent_bytes = { type = "bigint" },
    request_verb = {},
    request_url = {},
    request_proto = {},
    user_agent = {},
    ssl_cipher = {},
    ssl_protocol = {},
    target_group_arn = {},
    trace_id = {},
    domain_name = {},
    chosen_cert_arn = {},
    matched_rule_priority = {},
    request_creation_time = {},
    actions_executed = {},
    redirect_url = {},
    lambda_error_reason = {},
    target_port_list = {},
    target_status_code_list = {},
    classification = {},
    classification_reason = {},
    conn_trace_id = {},
    transformed_host = {},
    transformed_uri = {},
    request_transform_status = {}
  }
}

variable "additional_columns" {
  type = map(object({
    type = optional(string, "string")
  }))
  description = "Additional columns in order to match to the regex at the end of the main columns. Intention is to make adding columns easier"
  default = {}
}