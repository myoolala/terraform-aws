variable "domain" {
  type        = string
  description = "Domain(s) for the cert to be attached to"
  default     = null
}

variable "hosted_zone" {
  type        = string
  description = "Hosted zone to use for DNS verification, if applicable"
  default     = null
}

variable "private" {
  type        = string
  description = "Is the hosted zone public if appplicable"
  default     = null
}