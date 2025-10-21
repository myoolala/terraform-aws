variable "name" {
  type        = string
  description = "Name for the bucket"
}

# variable "account_id" {
#     type = string
#     description = "ID of the account that will need KMS access"
# }

variable "versioning_enabled" {
  type        = bool
  description = "Is versioning enabled for the bucket"
  default     = false
}