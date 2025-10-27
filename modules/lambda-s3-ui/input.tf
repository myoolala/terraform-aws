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

variable "config" {
  type = object({
    bucket                   = string,
    prefix                   = string,
    log_level                = optional(string, "INFO"),
    gz_assets                = optional(bool, false)
    cache_mapping            = optional(map(any), null)
    server_cache_ms          = optional(number, 5 * 60 * 1000)
    enable_spa               = optional(bool, false)
    default_file_path        = optional(string, "index.html")
    default_response_headers = optional(map(any), null)
  })
}

variable "sg_config" {
  type = object({
    create        = bool
    vpc_id        = string
    ingress_cidrs = optional(list(string), [])
    ingress_sgs   = optional(list(string), [])
    egress_cidrs  = optional(list(string), [])
    egress_sgs    = optional(list(string), [])
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
    sg_ids  = optional(list(string), [])
  })
  description = "VPC config to use"
  default = {
    subnets = null
    sg_ids  = null
  }
}

variable "alb_tg_arn" {
  type        = string
  description = "ARN of the ALB Target group that forward requests to the lambda"
}