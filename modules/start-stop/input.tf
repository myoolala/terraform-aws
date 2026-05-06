###########################################################################
###############                   Required                  ###############
###########################################################################

variable "name" {
  type        = string
  description = "Name to give the start/stop Lambda"
}

###########################################################################
###############                   Optional                  ###############
###########################################################################

variable "schedule" {
  type        = string
  description = "Schedule to run the start/stop Lambda on"
  default     = "cron(*/30 * * * ? *)"
}

variable "dry_run_mode_enabled" {
  type        = bool
  description = "Is dry run mode enabled in the Lambda or not"
  default     = false
}

variable "log_retention" {
  type        = number
  description = "Log retention in days for the Lambda"
  default     = 7
}

variable "timeout" {
  type        = number
  description = "Timeout for the Lambda function"
  default     = 60
}

variable "memory" {
  type        = number
  description = "Default memory allocation for the runtime"
  default     = 128
}

variable "sns_alert_topics" {
  type        = list(string)
  description = "List of SNS topic ARN's to send errors to"
  default     = []
}

variable "log_level" {
  type        = string
  description = "Log level for the lambda. Default is INFO"
  default     = "INFO"
}

variable "start_grace_period" {
  type        = number
  description = "Number of hours to allow premature starting of the instance"
  default     = 0
}

variable "permissions" {
  type        = string
  description = "JSON encoded permissions policy to override the default policy with"
  default     = null
}

variable "tag_to_search" {
  type = string
  description = "TAG to query for when running the stop start"
  default = "ServiceRunSchedule"
}