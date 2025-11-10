###########################################################################
###############                   Required                  ###############
###########################################################################

variable "name" {
  type        = string
  description = "Name to attach to the SQS Queue"
}

###########################################################################
###############                   Optional                  ###############
###########################################################################

variable "kms" {
  type = object({
    key             = string
    deletion_window = optional(number, 14)
    permissions     = optional(string, "")
  })
  description = "KMS configuration for the Queue. Defaults to no encryption"
  default = {
    key = null
  }
}

variable "policy" {
  type        = string
  description = "Policy to attach to the topic if applicable"
  default     = null
}

variable "delay_seconds" {
  type        = number
  description = "Time in seconds that the delivery of all messages in the queue will be delayed"
  default     = 0
}

variable "max_message_size" {
  type        = number
  description = "Limit of how many bytes a message can contain before Amazon SQS rejects it"
  default     = 262144
}

variable "message_retention_seconds" {
  type        = number
  description = "Number of seconds Amazon SQS retains a message"
  default     = 345600
}

variable "receive_wait_time_seconds" {
  type        = number
  description = "Time for which a ReceiveMessage call will wait for a message to arrive (long polling) before returning"
  default     = 0
}

variable "visibility_timeout_seconds" {
  type        = number
  description = "Visibility timeout for the queue"
  default     = 30
}
