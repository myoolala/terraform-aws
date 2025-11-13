###########################################################################
###############                   Required                  ###############
###########################################################################

variable "name" {
  type        = string
  description = "value"
}

variable "permissions" {
  type        = string
  description = "JSON encoded permissions string for any required DB/Secrets access"
}

variable "event_schedule_input" {
  type = object({
    rdsIdentifier        = string
    rdsAdminInfoLocation = string
    mode                 = optional(string, "instance")
    pwLength             = optional(number, 64)
  })
  description = "Information to pass to the lambda when invoked to rotate the password"
}

###########################################################################
###############                   Optional                  ###############
###########################################################################

variable "schedule" {
  type        = string
  description = "Schedule expression to trigger the lambda with if there is one. Make null if this gets shared with multiple databases"
  default     = "rate(30 days)"
}

variable "alerts_topic" {
  type        = string
  description = "Alert topic to send updates to if there is one"
  default     = null
}

variable "dy_run" {
  type        = bool
  description = "Is the lambda in dry run mode"
  default     = false
}

variable "log_level" {
  type        = string
  description = "Log level for the lambda function"
  default     = "INFO"
}