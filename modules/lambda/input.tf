variable "role" {
  type        = string
  description = "Existing role to attach to the lambda if desired"
  default     = null
}

variable "function_name" {
  type        = string
  description = "Name for the new lambda function"
}

variable "file_path" {
  type        = string
  description = "Path to the zip file to deploy if one is available"
  default     = null
}

variable "bucket" {
  type        = string
  description = "Name of the bucket to pull the code from"
  default     = null
}

variable "key" {
  type        = string
  description = "S3 Key of the source zip file"
  default     = null
}

variable "runtime" {
  type        = string
  description = "Runtime to use for the lambda"
  default     = "nodejs20.x"
}

variable "handler" {
  type        = string
  description = "Handler function"
  default     = "index.handler"
}

variable "log_retention" {
  type        = number
  description = "Number in days to store logs in cloudwatch"
  default     = 7
}

variable "environment_vars" {
  type        = map(string)
  default     = null
  description = "Environment variables to pass into the lambda"
}

variable "secrets" {
  type = object({
    arns     = list(string)
    kms_keys = list(string)
  })
  description = "List of secrets and associated kms keys the lambda will need access to"
  default = {
    arns     = []
    kms_keys = []
  }
}

variable "permissions" {
  type        = map(any)
  description = "Additional permissions the lambda will need"
  default     = null
}

variable "vpc_config" {
  type = object({
    subnet_ids = list(string)
    security_group_ids = list(string)
  })
  description = "VPC config for the lambda"
  default = null
}

variable "timeout" {
  type = number
  description = "Lambda timeout allowed"
  default = 3
}