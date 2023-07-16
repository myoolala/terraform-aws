variable "block_mappings" {
  type = list(object({
    name                  = string
    size                  = number
    delete_on_termination = optional(bool, true)
    encrypted             = optional(bool, true)
    iops                  = optional(string, null)
    kms_key               = optional(string, null)
    snapshot_id           = optional(string, null)
    type                  = optional(string, null)
  }))
  description = "Block mappings to attach to each server in the asg"
  default = [
    {
      name = "/dev/sdf"
      size = 20
    }
  ]
}

variable "metadata" {
  type = object({
    enabled   = optional(string, "enabled")
    tokens    = optional(string, "optional")
    hop_limit = optional(number, 1)
    tags      = optional(string, "enabled")
  })
  description = "Metadata properties to attach to the instances"
  default = {
    enabled   = "value"
    tokens    = "optional"
    hop_limit = 1
    tags      = "value"
  }
}