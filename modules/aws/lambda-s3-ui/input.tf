variable "make_new_bucket" {
  type        = bool
  description = "Is a new bucket to store the code desired"
  default     = false
}

variable "environment_vars" {
  type        = map(string)
  default     = null
  description = "Environment variables to pass into the lambda"
}

variable "bucket_name" {
  type        = string
  description = "Name of the bucket the code will be stored in"
}

variable "bucket_key" {
  type        = string
  description = "S3 URI for the lambda zip file"
}

variable "lambda_name" {
  type        = string
  description = "Name for the lambda function"
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

variable "path_prefix" {
  type        = string
  description = "Common path shared between all endpoints"
}

variable "protocol" {
  type        = string
  description = "Protocol for the lambda api"
  default     = "HTTP"
}

variable "lb" {
  type = object({
    vpc_id        = optional(string, null)
    subnets       = optional(list(string), null)
    # ingress_groups 
    ingress_cidrs = optional(list(string), ["0.0.0.0/0"])
    # egress_groups
    egress_cidrs = optional(list(string), ["0.0.0.0/0"])
    internal            = optional(bool, false)
    deletion_protection = optional(bool, false)
    port_mappings = list(object({
      listen_port  = number
      sg_protocol  = optional(string, "tcp")
      lb_protocol  = optional(string, "HTTPS")
      forward_port = number
      tg_protocol  = optional(string, "HTTPS")
      cert         = optional(string, null)
    }))
  })
}