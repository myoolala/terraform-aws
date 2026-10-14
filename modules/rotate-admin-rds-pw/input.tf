################################################################################
# Required Variables
################################################################################

variable "name" {
  description = "The name of the Lambda function to create."
  type        = string
}

variable "permissions" {
  description = "Additional IAM policy permissions for the lambda role. Must be JSON encoded array of policy statements."
  type        = any
}

variable "event_schedule_input" {
  description = "Event payload passed to the Lambda at runtime."
  type = object({
    rdsIdentifier        = string
    rdsAdminInfoLocation = string
    mode                 = optional(string, "instance")
    pwLength             = optional(number, 64)
  })
}

################################################################################
# Optional Variables
################################################################################

variable "schedule" {
  description = "Optional cron or rate expression to schedule automatic invocation of the lambda function."
  type        = string
  default     = "rate(30 days)"
}

variable "alerts_topic" {
  description = "ARN of an SNS topic to send alerts to."
  type        = string
  default     = null
}

variable "dy_run" {
  description = "Toggle dry run mode."
  type        = bool
  default     = false
}

variable "log_level" {
  description = "Logging level."
  type        = string
  default     = "INFO"
}

# New optional variables
variable "vpc_config" {
  description = "VPC configuration for the Lambda."
  type = object({
    id              = string
    subnets         = list(string)
    security_groups = optional(list(string))
  })
  default = null
}

variable "existing_code" {
  description = "If set, use an existing Lambda layer ARN or a path to a zip file."
  type        = string
  default     = null
}