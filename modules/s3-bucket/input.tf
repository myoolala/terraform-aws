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

variable "public_access_block" {
  type = object({
    block_public_acls = optional(bool, true)
    block_public_policy = optional(bool, true)
    ignore_public_acls = optional(bool, true)
    restrict_public_buckets = optional(bool, true)
  })
  description = "Public access block config for the bucket"
  default = {}
}

variable "encryption" {
  type = object({
    key                = optional(string, null)
    algorithm          = string
    bucket_key_enabled = optional(bool, false)
  })
  description = "Attach an encryption key to the bucket. Specify the key if you already have one, or use a different encryption option"
  default = {
    key = null
    algorithm          = "AES256"
    bucket_key_enabled = true
  }
}