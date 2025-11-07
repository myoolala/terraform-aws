variable "name" {
  type        = string
  description = "Name to attach to the SNS Topic"
}

variable "display_name" {
  type        = string
  description = "Display name to attach to the SNS Topic"
}

variable "kms" {
  type = object({
    key             = string
    deletion_window = optional(number, 14)
    permissions     = optional(string, "")
  })
  description = "Encryption configuration which defaults to no encyrption. Supports passing in a key or creating one with the Key 'create'"
  default = {
    key = null
  }
}

variable "policy" {
  type        = string
  description = "Policy to attach to the topic if applicable"
  default     = null
}