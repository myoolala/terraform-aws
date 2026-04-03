###########################################################################
###############                   Required                  ###############
###########################################################################

variable "service_name" {
  type        = string
  description = "Name to apply to the Fargate service"
}

variable "network" {
  type = object({
    vpc_id  = string
    subnets = optional(list(string), null)
  })
  description = "Network config to attach to the service containers"
}

variable "cluster" {
  type = object({
    create = optional(bool, false)
    name   = optional(string, null)
    arn    = optional(string, null)
  })
  description = "Cluster information for the service"
}

###########################################################################
###############                   Optional                  ###############
###########################################################################

variable "ecr" {
  type = object({
    create       = optional(bool, true)
    scan_on_push = optional(bool, true)
  })
  description = "ECR configuration for the service"
  default = {
    create       = true
    scan_on_push = true
  }
}

variable "desired_count" {
  type        = number
  default     = 2
  description = "Initial desired count of containers for the service"
}

variable "image_tag" {
  type        = string
  description = "Version of the app in ECR to deploy"
  default     = null
}

variable "tags" {
  type        = map(any)
  description = "Tags to apply to all resources. Ie: environment, cost tracking, etc..."
  default     = {}
}

variable "log_retention" {
  type        = number
  default     = 7
  description = "Number of days to store the service logs for"
}

variable "env_vars" {
  type        = map(string)
  default     = {}
  description = "Environment variables to pass to the container in {<key> = <value>, <key> = <value>} form"
}

variable "secrets" {
  type        = list(map(string))
  default     = []
  description = "List of secrets to attach to the service"
}

variable "command" {
  type        = list(string)
  description = "Description to pass to the task definition"
  default     = null
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
  description = "Load balancer configuration for the service if there is one"
  default     = null
}

variable "target_groups" {
  type = list(object({
    arn            = string
    container_port = number
  }))
  description = "List of existing target groups to associate with the service"
  default     = []
}

variable "default_egress" {
  type = object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  })
  description = "Default egress rule for the created security group"
  default = {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

variable "propagate_tags" {
  type        = string
  description = "Should the tags from the task definition propagate to the instances"
  default     = null
}