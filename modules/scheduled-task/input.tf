###########################################################################
###############                   Required                  ###############
###########################################################################

variable "service_name" {
  type        = string
  description = "Name to apply to the Fargate service"
}

variable "vpc_id" {
  type        = string
  description = "VPC to run the service in"
}

variable "cluster" {
  type = object({
    create = optional(bool, true)
    name   = optional(string, null)
    arn    = optional(string, null)
  })
  description = "Cluster configuration to attach to the scheduled task"
}

variable "service_subnets" {
  type        = list(string)
  description = "Subnets to run the service in"
}

variable "trigger" {
  type        = object({
    schedule_expression = optional(string, null)
    event_pattern = optional(string, null)
  })
  description = "Trigger for a scheduled task"
}

###########################################################################
###############                   Optional                  ###############
###########################################################################

variable "scan_on_push" {
  type        = bool
  description = "Have ECR scan images on push"
  default     = true
}

variable "create_ecr_repo" {
  type        = bool
  description = "Create a new ecr repo or not"
  default     = true
}

variable "image_tag" {
  type        = string
  description = "Version of the app in ECR to deploy"
  default     = null
}

variable "permissions" {
  type        = string
  default     = null
  description = "Json encoded string of permissions to attach to the container"
}

variable "public" {
  type        = string
  description = "Should the docker containers get assigned public ip's"
  default     = false
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
  type = list(object({
    name     = optional(string)
    value    = string
    env_name = string
    create   = optional(bool, false)
  }))
  default     = []
  description = "List of secrets to attach to the service"
}

variable "memory" {
  type        = number
  default     = 512
  description = "Memory amount in MB to give to the docker definition"
}

variable "cpu" {
  type        = number
  default     = 256
  description = "CPU value to give to the docker definition"
}

variable "storage" {
  type        = number
  default     = 21
  description = "Amount of storage, in GB, to allocate to the container"
}

variable "input" {
  type        = string
  description = "Input overrides to attach to the task if there are any"
  default     = null
}

variable "encrypt_logs" {
  type = object({
    enabled      = bool
    existing_key = optional(string, null)
  })
  description = "Do you want the cloudwatch logs encrypted"
  default = {
    enabled = false
  }
}