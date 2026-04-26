variable "secrets" {
  type        = list(map(string))
  default     = []
  description = "Map of secrets to store in aws secrets manager"
}

variable "kms_key_id" {
  type        = string
  default     = "alias/aws/secretsmanager"
  description = "Name of the kms key to associate with the secrets"
}

variable "create_new_key" {
  type        = bool
  default     = true
  description = "Create a new key to encrypt the secrets data with instead of using the provided key"
}

variable "recovery_window" {
  type        = number
  default     = 7
  description = "Number of days, 0 to 30, to store a deleted secret in order to recover it"
}