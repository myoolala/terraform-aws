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
  type        = list(string)
  default     = null
  description = "SSM Parameter Store paths to store the credentials. Optional; multiple ARNs supported."
}

variable "secretsmanager_secret" {
  type        = list(string)
  default     = null
  description = "Secrets Manager secret ARNs to store the credentials. Optional; multiple ARNs supported."
}

variable "sns_topic" {
  type        = list(string)
  default     = null
  description = "SNS topic ARNs to publish error messages. Optional; multiple ARNs supported."
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
