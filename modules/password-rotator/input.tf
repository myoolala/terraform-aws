# Required Variables
################################################################################
# Required Variables
################################################################################

variable "lambda_function_name" {
  description = "The name of the Lambda function to create."
  type        = string
}

# Optional Variables
################################################################################
# Optional Variables
################################################################################

variable "vpc_subnet_ids" {
  description = "Optional list of subnet IDs for VPC configuration."
  type        = list(string)
  default     = []
}

variable "vpc_security_group_ids" {
  description = "Optional list of security group IDs for VPC configuration."
  type        = list(string)
  default     = []
}

variable "lambda_layer_arn" {
  description = "Optional ARN of a Lambda layer to attach."
  type        = string
  default     = null
}

variable "default_password_config" {
  description = "JSON string providing default configuration for password rotation."
  type        = string
  default     = null
}

variable "service_rotation" {
  description = "Optionally force service rotation. Allowed values: fargate, asg, lambda."
  type        = string
  validation {
    condition     = can(regex("^(fargate|asg|lambda)$", var.service_rotation)) || var.service_rotation == null
    error_message = "service_rotation must be one of fargate, asg, or lambda."
  }
  default     = null
}

variable "force_rotate_env_var" {
  description = "Time in milliseconds to force rotate the Lambda environment."
  type        = string
  default     = null
}

variable "lambda_timeout" {
  description = "Timeout in seconds for the Lambda function."
  type        = number
  default     = 30
}


variable "schedule" {
  description = "Optional cron or rate expression to schedule automatic invocation of the lambda function."
  type        = string
  default     = "rate(90 days)"
}

variable "memory" {
  description = "Memory allocation per runtime for the lambda function."
  type        = number
  default     = 128
}
