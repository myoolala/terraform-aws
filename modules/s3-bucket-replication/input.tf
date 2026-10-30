variable "source_bucket_name" {
  type        = string
  description = "Name of the existing source bucket to replicate from"
}

variable "backup_bucket_name" {
  type        = string
  description = "Name of the backup bucket to create. Defaults to <source>-backup if omitted."
  default     = ""
}

variable "replication_mode" {
  type        = string
  description = "Replication direction: 'one-way' or 'two-way'"
  default     = "one-way"
  validation {
    condition     = contains(["one-way", "two-way"], var.replication_mode)
    error_message = "replication_mode must be 'one-way' or 'two-way'"
  }
}

variable "public_access_block" {
  type = object({
    block_public_acls       = optional(bool, true)
    block_public_policy     = optional(bool, true)
    ignore_public_acls      = optional(bool, true)
    restrict_public_buckets = optional(bool, true)
  })
  description = "Public access block config for the backup bucket"
  default     = {}
}
