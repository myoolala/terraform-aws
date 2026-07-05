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