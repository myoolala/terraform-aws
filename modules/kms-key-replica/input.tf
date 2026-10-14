variable "source_key_arn" {
  type        = string
  description = "ARN of the source key to replicate"
}

variable "permissions" {
  type        = string
  description = "Optional JSON policy to incorporate into the replica key policy"
  default     = null
}

variable "description" {
  type        = string
  description = "Optional description for the replica key"
  default     = null
}

variable "replica_alias" {
  type        = string
  description = "Alias to assign to the replica key, if desired"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the replica key"
  default     = {}
}
