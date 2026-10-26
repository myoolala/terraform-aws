################################################################################
# Required Variables
################################################################################
variable "application_name" {
  description = "The name of the Elastic Beanstalk application."
  type        = string
}

variable "solution_stack_name" {
  description = "The name of the solution stack for the environment."
  type        = string
}

variable "instance_types" {
  description = "Allowed EC2 instance types, in priority order."
  type        = list(string)

  validation {
    condition     = length(var.instance_types) > 0
    error_message = "Provide at least one EC2 instance type."
  }
}

################################################################################
# Optional Variables
################################################################################
variable "environment_name" {
  description = "Name of the Elastic Beanstalk environment. Defaults to application_name."
  type        = string
  default     = null
}

variable "application_version_label" {
  description = "Label of the application version. If omitted, a timestamped value will be used."
  type        = string
  default     = null
}

variable "source_code_path" {
  description = "Local directory path to source code for creating a bundle. Not required when using pre-uploaded S3 objects."
  type        = string
  default     = null
}

variable "s3_bucket" {
  description = "S3 bucket where the application bundle is stored. Required if source_code_path is not provided."
  type        = string
  default     = null
}

variable "s3_key" {
  description = "S3 key for the application bundle. Required if source_code_path is not provided."
  type        = string
  default     = null
}

variable "create_bucket" {
  description = "Whether to create a new S3 bucket for the bundle when source_code_path is provided."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags to apply to resources."
  type        = map(string)
  default     = {}
}

variable "settings" {
  description = "Additional Beanstalk settings, grouped by namespace."
  type        = map(map(string))
  default     = {}

  validation {
    condition = !contains(
      keys(lookup(var.settings, "aws:ec2:instances", {})),
      "InstanceTypes"
    )
    error_message = "Configure InstanceTypes through instance_types."
  }
}