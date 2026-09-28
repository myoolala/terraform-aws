# input.tf

################################################################################
# Required Variables
################################################################################

variable "name" {
  description = "Name used to identify the WAF Web ACL and associated resources."
  type        = string
}

variable "default_action" {
  description = "The default action for the Web ACL. Must be one of ALLOW or BLOCK."
  type        = string
}

################################################################################
# Optional Variables
################################################################################

variable "scope" {
  description = "The scope of the Web ACL. Defaults to REGIONAL."
  type        = string
  default     = "REGIONAL"
}

variable "tags" {
  description = "Additional tags to apply to resources created by this module."
  type        = map(string)
  default     = {}
}

variable "alb_arn" {
  description = "ARN of the ALB to associate this Web ACL with. Optional."
  type        = string
  default     = null
}

variable "managed_rule_groups" {
  description = "List of AWS managed rule groups to include. Each item must contain name and vendor."
  type = list(object({
    name           = string
    vendor         = string
    excluded_rules = optional(list(string), [])
  }))
  default = []
}

variable "ip_sets" {
  description = "Custom IP allow or block lists. Each item must contain name, addresses, and action."
  type = list(object({
    name      = string
    addresses = list(string)
    action    = string
  }))
  default = []
}

