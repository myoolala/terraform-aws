variable "name" {
  type        = string
  description = "Name for the db instance"
}

variable "vpc_config" {
  type = object({
    vpc_id                 = string
    subnets                = list(string)
    sg_ids                 = optional(list(string), [])
    ingress_cidr_whitelist = optional(list(string), [])
    ingress_sg_whitelist   = optional(list(string), [])
    egress_cidr_whitelist  = optional(list(string), [])
    egress_sg_whitelist    = optional(list(string), [])
  })
}

variable "network_type" {
  type        = string
  description = "Network Type for the instance, defaults to IPV4 <IPV4|DUAL>"
  default     = "IPV4"
}

variable "port" {
  type        = number
  description = "Port the db instance is listening on"
}

variable "pg_name" {
  type        = string
  description = "Parameter group name"
  default     = null
}

variable "auto_minor_version_upgrade" {
  type        = bool
  description = "Allow minor upgrades, default false"
  default     = false
}

variable "allow_major_version_upgrade" {
  type        = bool
  description = "Allow major upgrades, default false"
  default     = false
}

variable "db_image" {
  type        = string
  description = "Snapshot identifier of the db instance if available"
  default     = null
}

variable "allocated_storage" {
  type        = number
  description = "Allocated storage in GB for the instance"
  default     = 20
}

variable "backup_retention_period" {
  type        = number
  description = "Number of days to store snapshot backups for"
  default     = 0
}

variable "max_allocated_storage" {
  type        = number
  description = "Max allocated storage for the isntance"
  default     = null
}

variable "multi_az" {
  type        = bool
  description = "Do you want a replicated db instance?"
  default     = true
}

variable "instance_class" {
  type        = string
  description = "Instance class for the db"
  default     = "db.t3.medium"
}

variable "admin_uname" {
  type        = string
  description = "Username for the admin account on the instance"
  default     = "main"
}

variable "admin_default_password" {
  type        = string
  description = "Default password that a good developer will definitely change after the instance is deployed"
  default     = "oh-pl3a$3-change-this"
}

variable "engine" {
  type        = string
  description = "Engine to run the db instance with"
}

variable "engine_version" {
  type        = string
  description = "Specific engine version to use if any"
  default     = null
}

variable "param_group_family" {
  type        = string
  description = "Specific engine version to use if any"
}

variable "param_group_suffix" {
  type        = string
  description = "Suffix for the param group name to use"
  default     = ""
}

variable "db_name" {
  type        = string
  description = "Name of the db to create if applicable"
  default     = null
}

variable "storage_encrypted" {
  type        = bool
  description = "Store all database data encrypted at rest"
  default     = true
}

variable "parameter_group_name" {
  type        = string
  description = "Name of the parameter group to use on the instance if any"
  default     = null
}

variable "parameters" {
  type = list(object({
    name         = string
    value        = string
    apply_method = optional(string, "pending-reboot")
  }))
}

variable "options_group_name" {
  type        = string
  description = "Name of the options group to use on the instance if any"
  default     = null
}

variable "final_snapshot_id" {
  type        = string
  description = "Manually set final snapshot identifier for the instance. One is auto generated if the id is set to an empty string. null means do not set one"
  default     = null
}

variable "maintenance_window" {
  type        = string
  description = "Maintenance window for the instance"
  default     = "Fri:02:00-Fri:04:00"
}

variable "rds_backup_window" {
  type        = string
  description = "Backup window for the instance"
  default     = "04:00-06:00"
}

variable "free_storage_space_threshold" {
  type        = number
  description = "Storage level to trigger an alarm"
  # This value should be 25% of rds_allocated_storage_in_gb. A setting of 25%
  # should give admins enough time to address low disk space issues.
  # 451 GB * 0.25 = 112.75 GB.
  # 112.75 GB * (1024^3) = 121,064,390,656 bytes
  default = null #20 * .25 * 1024 * 1024 * 1024
}

variable "alarm_arns" {
  type        = list(string)
  description = "List of ARN's for the sns topic to send alerts to"
  default     = []
}

variable "publicly_accessible" {
  type    = bool
  default = false
}

variable "ca" {
  type    = string
  default = null
}

variable "storage_type" {
  type    = string
  default = null
}