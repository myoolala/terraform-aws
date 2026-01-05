###########################################################################
###############                   Required                  ###############
###########################################################################

variable "name" {
  type        = string
  description = "Name for the Cognito User Pool"
}

###########################################################################
###############                   Optional                  ###############
###########################################################################

variable "groups" {
  type = list(object({
    name        = string
    description = string
    precidence  = optional(number, 100)
    role_arn    = optional(string, null)
    # permissions = optional(string, null)
  }))
  description = "List of groups to create along side the Cognito User Pool"
  default     = []
}

variable "client_config" {
  type = object({
    name                                 = string
    callback_urls                        = list(string)
    allowed_oauth_flows_user_pool_client = optional(bool, true)
    allowed_oauth_flows                  = list(string)
    allowed_oauth_scopes                 = list(string)
    supported_identity_providers         = list(string)
  })
  description = "Configuration for the client if there is one"
  default     = null
}

variable "domain" {
  type = string
  description = "Domain to add to the pool if there is one. If you want a FQDN, leave null and manually create"
  default = null
}

variable "tags" {
  type        = map(string)
  description = "Default tags to apply to the resources"
  default = {

  }
}