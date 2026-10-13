################################################################################
# Required Variables
################################################################################

variable "lambda_function_name" {
  description = "The name of the Lambda function to create."
  type        = string
}

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

variable "permissions" {
  description = "Additional IAM policy permissions for the lambda role. Must be JSON encoded array of policy statements."
  type        = any
  default     = null
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

variable "secrets" {
  type = object({
    arns     = list(string)
    kms_keys = list(string)
  })
  description = "Secrets ARNs and associated KMS key ARNs the lambda will need access to"
  default = {
    arns     = []
    kms_keys = []
  }
}
