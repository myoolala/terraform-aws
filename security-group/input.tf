variable "name" {
  type        = string
  description = "Name for the security group"
}

variable "vpc_id" {
  type        = string
  description = "VPC to house the SG"
}

variable "ingresses" {
  type = list(object({
    from_port                = number
    to_port                  = number
    protocol                 = string
    source_security_group_id = optional(string, null)
    cidr_blocks              = optional(list(string), null)
  }))
  description = "List of ingress rules to attach in an inline method without ruining everyone's day"
  default     = []
}

variable "egresses" {
  type = list(object({
    from_port                = number
    to_port                  = number
    protocol                 = string
    source_security_group_id = optional(string, null)
    cidr_blocks              = optional(list(string), null)
  }))
  description = "List of egress rules to attach in an inline method without ruining everyone's day"
  default = [{
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }]
}