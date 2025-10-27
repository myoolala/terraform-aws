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

variable "buildspec_path" {
  type        = string
  description = "Path in the file system to the buildspec file"
  default     = null
}

variable "environment" {
  type = object({
    compute_type                = optional(string, "BUILD_GENERAL1_SMALL")
    image                       = optional(string, "aws/codebuild/amazonlinux2-x86_64-standard:4.0")
    type                        = optional(string, "LINUX_CONTAINER")
    image_pull_credentials_type = optional(string, "CODEBUILD")
    environment_variables       = optional(map(string), {})
  })
  description = "Environment config for the project"
  default     = {}
}

variable "vpc_config" {
  type = object({
    vpc_id     = string
    subnet_ids = list(string)
    sg_ids     = list(string)
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