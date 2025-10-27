variable "name" {
  type        = string
  description = "Name for the pipeline"
}

variable "stages" {
  type = list(object({
    name             = string
    category         = string
    owner            = optional(string, "AWS")
    provider         = string
    input_artifacts  = optional(list(string), [])
    output_artifacts = optional(list(string), [])
    version          = string
    configuration    = map(any)
    codebuild_project = optional(object({
      create         = bool
      name           = optional(string, null)
      description    = optional(string, null)
      buildspec_path = optional(string, null)
      environment = optional(object({
        compute_type                = optional(string, "BUILD_GENERAL1_SMALL")
        image                       = optional(string, "aws/codebuild/amazonlinux2-x86_64-standard:4.0")
        type                        = optional(string, "LINUX_CONTAINER")
        image_pull_credentials_type = optional(string, "CODEBUILD")
        environment_variables       = optional(map(string), {})
      }), {})
      vpc_config = optional(object({
        vpc_id     = string
        subnet_ids = list(string)
        sg_ids     = list(string)
      }), null)
      }), {
      create = false
    })
  }))
  description = "List of stages to build and use"
}

variable "artifact_store" {
  type = object({
    create      = bool
    bucket_id   = optional(string, null)
    bucket_arn  = optional(string, null)
    kms_key_arn = optional(string, null)
  })
  description = "Artifact store to use with the pipeline if there is one"
  default = {
    create = false
  }
}

variable "iam_role" {
  type        = string
  description = "Existing IAM role to use for the pipeline. Leave null to create one"
  default     = null
}