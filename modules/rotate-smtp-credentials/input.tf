################################################################################
# Required Variables
################################################################################

variable "name" {
  type        = string
  description = "The name of the Lambda function to create."
}

variable "iam_user" {
  type        = string
  description = "IAM username whose credentials will be rotated."
}

################################################################################
# Optional Variables
################################################################################

variable "ssm_parameter" {
  type        = string
  default     = null
  description = "SSM Parameter Store paths to store the credentials. Optional"
}

variable "secretsmanager_secret" {
  type        = string
  default     = null
  description = "Secrets Manager secret ARN to store the credentials. Optional"
}

variable "sns_topic" {
  type        = string
  default     = null
  description = "SNS topic ARN to publish error messages. Optional"
}

variable "existing_code" {
  type        = string
  default     = null
  description = "ARN of an existing Lambda layer or a path to a zip file to override the default hook layer."
}

variable "permissions" {
  type        = any
  default     = null
  description = "JSON encoded IAM policy statements to merge with the required permissions."
}

variable "vpc_config" {
  type = object({
    id              = string
    subnets         = list(string)
    security_groups = optional(list(string))
  })
  default     = null
  description = "VPC configuration for the Lambda."
}

variable "schedule" {
  type        = string
  default     = null
  description = "Cron or rate expression to schedule automatic invocation of the Lambda."
}

variable "additonal_environment_vars" {
  type        = map(string)
  default     = {}
  description = "Environment variables to pass or override into the lambda"
}

variable "memory" {
  description = "Memory allocation per runtime for the lambda function."
  type        = number
  default     = 512
}

variable "timeout" {
  description = "Max allowed run time for the lambda"
  type        = number
  default     = 60
}