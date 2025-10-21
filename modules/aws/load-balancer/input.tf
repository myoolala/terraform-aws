variable "vpc_id" {
  type        = string
  description = "ID of the vpc to host the LB in"
}

variable "subnets" {
  type        = list(string)
  description = "List of subnets to host the load balancer in. Recommend at least 2"
}

variable "ingress_cidrs" {
  type        = list(string)
  description = "List of cidr ingresses to attach to the load balancer"
  default     = []
}

variable "ingress_groups" {
  type        = list(string)
  description = "List of security group ingresses to attach to the load balancer"
  default     = []
}

variable "egress_cidrs" {
  type        = list(string)
  description = "List of cidr ingresses to attach to the load balancer"
  default     = ["0.0.0.0/0"]
}

variable "egress_groups" {
  type        = list(string)
  description = "List of security group ingresses to attach to the load balancer"
  default     = []
}

variable "security_group" {
  type        = string
  description = "Existing security group to use instead of creating one"
  default     = null
}

variable "name" {
  type        = string
  description = "Name for the load balancer and associated resources"
}

variable "type" {
  type        = string
  description = "Load balancer type to stand up"
  default     = "application"
}

variable "internal" {
  type        = bool
  description = "Is the load balancer internal or external"
  default     = false
}

variable "deletion_protection" {
  type        = bool
  description = "Is the load balancer protected from deletion?"
  default     = false
}

variable "port_mappings" {
  type = list(object({
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
  description = "Port listener mappings with associated the load balancer"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Default tags to associate with the resources"
  default     = {}
}