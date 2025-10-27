variable "name" {
  type        = string
  description = "Name for the pipeline"
}

variable "description" {
  type        = string
  description = "Description for the codebuild project"
}

variable "build_timeout" {
  type        = number
  description = "Build timeout for the project in minutes"
  default     = 5
}

variable "source_config" {
  type = object({
    type      = string
    buildspec = optional(string, null)
  })
  description = "Source config as per the AWS provider documentation"
}

variable "environment" {
  type = object({
    compute_type                = optional(string, "BUILD_GENERAL1_SMALL")
    image                       = optional(string, "aws/codebuild/amazonlinux2-x86_64-standard:4.0")
    type                        = optional(string, "LINUX_CONTAINER")
    image_pull_credentials_type = optional(string, "CODEBUILD")
    privileged_mode             = optional(bool, false)
    environment_variables = optional(list(object({
      name  = string
      value = string
      type  = optional(string, null)
    })), [])
  })
  description = "Environment config for the project"
  default     = {}
}

variable "vpc_config" {
  type = object({
    vpc_id      = string
    subnet_ids  = list(string)
    subnet_arns = list(string)
    sg_ids      = optional(list(string), [])
    create_sg   = optional(bool, false)
  })
  description = "VPC config to host the system in if there is one"
  default     = null
}

variable "default_tags" {
  type        = map(string)
  description = "Default tags to apply to resources"
  default = {
  }
}

variable "cw_log_config" {
  type = object({
    group_name  = optional(string, null)
    stream_name = optional(string, null)
  })
  description = "CloudWatch logging config"
  default = {
  }
}

variable "s3_log_config" {
  type = object({
    status              = string
    location            = optional(string, null)
    encrypted           = optional(bool, true)
    bucket_owner_access = optional(string, null)
  })
  description = "S3 logging config"
  default = {
    status = "DISABLED"
  }
}

variable "cache" {
  type = object({
    type     = string
    location = optional(string, null)
    modes    = optional(list(string), null)
  })
  description = "Cache field for the codebuild project"
  default = {
    type = "NO_CACHE"
  }
}