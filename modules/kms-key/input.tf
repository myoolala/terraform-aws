###########################################################################
###############                   Required                  ###############
###########################################################################

variable "description" {
  type        = string
  description = "Description for the KMS key"
}

###########################################################################
###############                   Optional                  ###############
###########################################################################

variable "is_enabled" {
  type        = bool
  description = "Is the key currently enabled"
  default     = true
}

variable "rotation_period" {
  type        = number
  description = "Rotation period to set on the key if there is one"
  default     = null
}

variable "deletion_window_in_days" {
  type        = number
  description = "Deletion windon in day. Defaults to 7"
  default     = 7
}

variable "enable_whole_account_access" {
  type        = bool
  description = "Enable the whole account to be allowed to be given permissions to the key. Disable if absolutely necessary"
  default     = true
}

variable "permissions" {
  type        = string
  description = "JSON policy to incorporate and possible override the 'Default' Sid policy statement with"
  default     = null
}

variable "alias" {
  type        = string
  description = "Alias to assign to the key if there is one"
  default     = null
}

variable "key_usage" {
  type        = string
  description = "Key Usage field to set on the key. Defaults to ENCRYPT_DECRYPT"
  default     = "ENCRYPT_DECRYPT"
}

variable "tags" {
  type        = map(string)
  description = "Default tags to apply to the resources"
  default = {
  }
}