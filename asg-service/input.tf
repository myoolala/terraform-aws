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

variable "network" {
  type = object({
    vpc            = string
    subnets        = list(string)
    additional_sgs = optional(list(string), [])
    ingresses = optional(list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      source_sg   = optional(string, null)
      cidr_blocks = optional(list(string), null)
    })), [])
  })
  description = "Network config for the ASG"
}

variable "ami" {
  type        = string
  description = "AMI to deploy to the group"
}

variable "instance_type" {
  type        = string
  description = "Instance type to deploy"
}

variable "public" {
  type        = bool
  description = "associate a public ip to the instances"
  default     = false
}

variable "metadata" {
  type = object({
    enabled   = optional(string, "enabled")
    tokens    = optional(string, "optional")
    hop_limit = optional(number, 1)
    tags      = optional(string, "enabled")
  })
  description = "Metadata properties to attach to the instances"
  default     = {}
}

variable "ebs_optimized" {
  type        = bool
  description = "To enable the ASG to be ebs optimized"
  default     = true
}

variable "protections" {
  type = object({
    scale_in_protection    = optional(bool, false)
    termination_protection = optional(bool, false)
    stop_protection        = optional(bool, false)
  })
  description = "Protection config"
  default     = {}
}

variable "key_name" {
  type        = string
  description = "SSH key to attach to the instances"
  default     = null
}

variable "name" {
  type        = string
  description = "Name for the autoscaling group and associated resources"
}

variable "managed_policies" {
  type        = list(string)
  description = "List of managed policies to attach to the group"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Map of tags to apply to all resources"
  default     = {}
}

variable "permissions" {
  type        = string
  default     = null
  description = "Json encoded string of permissions to attach to the container"
}

variable "capacity" {
  type = object({
    initial               = optional(number, 1)
    max                   = optional(number, 2)
    min                   = optional(number, 1)
    max_instance_lifetime = optional(number, null)
  })
  description = "Capacity config for the group"
  default     = {}
}

variable "config" {
  type = object({
    health_check_type       = optional(string, "ELB")
    grace_period            = optional(number, 300)
    service_linked_role_arn = optional(string, null)
    termination_policies    = optional(list(string), [])
    suspended_processes     = optional(list(string), [])
  })
  description = "Main ASG config"
  default     = {}
}

variable "lb" {
  type = object({
    vpc_id        = optional(string, null)
    subnets       = optional(list(string), null)
    ingress_cidrs = optional(list(string), ["0.0.0.0/0"])
    # ingress_groups 
    egress_cidrs = optional(list(string), ["0.0.0.0/0"])
    # egress_groups
    type                = optional(string, "application")
    internal            = optional(bool, false)
    deletion_protection = optional(bool, false)
    port_mappings = list(object({
      listen_port  = number
      sg_protocol  = optional(string, "tcp")
      lb_protocol  = optional(string, "HTTPS")
      forward_port = number
      tg_protocol  = optional(string, "HTTPS")
      cert         = optional(string, null)
      target_type  = optional(string, "ip")
      health_check = optional(object({
        enabled             = optional(bool, true)
        matcher             = optional(string, "200-499")
        interval            = optional(number, 30)
        healthy_threshold   = optional(number, 2)
        unhealthy_threshold = optional(number, 4)
        service_protocol    = optional(string, "HTTPS")
        path                = optional(string, "/")
      }), {})
    }))
  })
}