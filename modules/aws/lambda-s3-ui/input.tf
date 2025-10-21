variable "environment_vars" {
  type        = map(string)
  default     = null
  description = "Environment variables to pass into the lambda"
}

variable "bucket_name" {
  type        = string
  description = "Name of the bucket the code will be stored in"
  default     = null
}

variable "bucket_key" {
  type        = string
  description = "S3 URI for the lambda zip file"
  default     = null
}

variable "lambda_name" {
  type        = string
  description = "Name for the lambda function"
}

variable "sg_config" {
  type = object({
    create = bool
    vpc_id = string
    ingress_cidrs = optional(list(string), [])
    ingress_sgs = optional(list(string), [])
    egress_cidrs = optional(list(string), [])
    egress_sgs = optional(list(string), [])
  })
  description = "Existing security group to use if there is one"
  default = {
    create = false
    vpc_id = null
  }
}

variable "vpc_config" {
  type = object({
    subnets = list(string)
    sg_ids = optional(list(string), [])
  })
  description = "VPC config to use"
  default = {
    subnets = null
    sg_ids = null
  }
}