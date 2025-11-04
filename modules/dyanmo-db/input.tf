##################################################################
#########                     Required                   #########
##################################################################

variable "name" {
  type        = string
  description = "The name for the table"
}

variable "hash_key" {
  type        = string
  description = "The hash key for the table. This must also be an attribute"
}

##################################################################
#########                     Optional                   #########
##################################################################

variable "range_key" {
  type        = string
  description = "The Range/Sort key for the table if there is one"
  default     = null
}

variable "attributes" {
  type = list(object({
    name = string
    type = string
  }))
  description = "List of attributes to assign to the table"
  default     = []
}

variable "encryption" {
  type = object({
    enabled     = optional(bool, true)
    kms_key_arn = optional(string, null)
  })
  description = "Encryption config to use for the table"
}

variable "backups" {
  type = object({
    enabled                 = optional(bool, true)
    recovery_period_in_days = optional(number, 7)
  })
  description = "Backup configuration for the database, defaults to 7 days PIT recovery"
  default = {
    enabled = true
  }
}

variable "ttl_field" {
  type        = string
  description = "TTL field to use from the attribute list if there is one"
  default     = null
}

variable "billing_mode" {
  type        = string
  description = "Billing mode to apply to the table"
  default     = "ON_DEMAND"
}

variable "read_capacity" {
  type        = string
  description = "Read capacity for the table if the billing mode is provisioned"
  default     = null
}

variable "write_capacity" {
  type        = string
  description = "Write capacity for the table if the billing mode is provisioned"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Default tags to apply to all resources in the module"
  default = {
  }
}

variable "gsis" {
  type = list(object({
    name               = string
    hash_key           = string
    range_key          = optional(string, null)
    write_capacity     = optional(number, null)
    read_capacity      = optional(number, null)
    projection_type    = string
    non_key_attributes = list(string)
  }))
  description = "List of GSI tables to create"
  default     = []
}

variable "lsis" {
  type = list(object({
    name               = string
    range_key          = string
    projection_type    = string
    non_key_attributes = optional(list(string), [])
  }))
  description = "List of Local Secondary Indexes to create if there are any"
  default     = []
}

variable "replica_regions" {
  type        = list(string)
  description = "List of other regions to use for a global table"
  default     = []
}
