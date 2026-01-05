###########################################################################
###############                   Required                  ###############
###########################################################################

variable "name" {
  type        = string
  description = "Name for the SOCI image indexer"
}

variable "cluster" {
  type = object({
    create = optional(bool, true)
    name   = optional(string, null)
    arn    = optional(string, null)
  })
  description = "Cluster configuration to attach to the scheduled task"
}

variable "vpc" {
  type = object({
    id      = string
    subnets = list(string)
  })
  description = "VPC configuration to host the Fargate task in"
}

###########################################################################
###############                   Optional                  ###############
###########################################################################

variable "code_bucket_config" {
  type = object({
    id     = string
    arn    = string
    prefix = string
  })
  description = "Existing code bucket to use if there is one"
  default     = null
}

variable "event_filter_override" {
  type        = string
  description = "JSON encoded filter to use in place of the default event filter"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources in the module"
  default     = {}
}