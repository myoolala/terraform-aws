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