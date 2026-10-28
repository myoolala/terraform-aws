##################################################################
#########                     Required                   #########
##################################################################

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

variable "port" {
  type        = number
  description = "Port the db instance is listening on"
}

variable "configs" {
  type = map(object({
    parameter_group_name   = optional(string, null)
    engine                 = string
    engine_version         = string
    parameter_group_family = string
    parameter_group_suffix = optional(string, "")
    option_group_name      = optional(string, null)
    parameters = optional(list(object({
      name         = string
      value        = string
      apply_method = optional(string, "pending-reboot")
    })), [])
  }))
  description = "Engine configurations. All parameter groups are created; selected_config chooses the active engine and group. Keep names unique across configurations."
  validation {
    condition     = length(var.configs) > 0
    error_message = "configs must contain at least one entry."
  }
}

##################################################################
#########                     Optional                   #########
##################################################################

variable "create_sg" {
  type        = bool
  description = "Create a new SG for the RDS database"
  default     = true
}

variable "network_type" {
  type        = string
  description = "Network Type for the instance, defaults to IPV4 <IPV4|DUAL>"
  default     = "IPV4"
}

variable "selected_config" {
  type        = string
  description = "Which configuration to use from the config variable"
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
  default     = 7
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
  description = "List of ARN's of the sns topics to send alerts to"
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

variable "skip_final_snapshot" {
  type        = bool
  description = "Skip the final snapshot on deletion"
  default     = false
}

variable "kms_key_id" {
  type        = string
  default     = null
  description = "KMS key ARN for encrypted database storage; snapshot restores inherit their source key."
}


variable "license_model" {
  type        = string
  default     = null
  description = "License model. Use license-included for RDS SQL Server."
}


variable "deletion_protection" {
  type        = bool
  default     = true
  description = "Protect the instance from deletion until explicitly disabled."
}


variable "copy_tags_to_snapshot" {
  type        = bool
  default     = true
  description = "Copy database instance tags to snapshots."
}


variable "delete_automated_backups" {
  type        = bool
  default     = false
  description = "Whether automated backups are deleted with the instance."
}


variable "apply_immediately" {
  type        = bool
  default     = false
  description = "Apply changes immediately instead of during the maintenance window."
}


variable "enabled_cloudwatch_logs_exports" {
  type        = set(string)
  default     = []
  description = "Engine-supported log types to export. SQL Server supports error and agent."
}


variable "monitoring_interval" {
  type        = number
  default     = 0
  description = "Enhanced Monitoring interval in seconds; zero disables it."
}


variable "monitoring_role_arn" {
  type        = string
  default     = null
  description = "IAM role ARN for Enhanced Monitoring."
}


variable "manage_master_user_password" {
  type        = bool
  default     = false
  description = "Use RDS-managed Secrets Manager credentials. Explicitly enable for the secure caller configuration."
}


variable "master_user_secret_kms_key_id" {
  type        = string
  default     = null
  description = "KMS key ARN for the RDS-managed master secret."
}


variable "password" {
  type        = string
  default     = null
  description = "Optional administrator password for unmanaged credentials. Stored in Terraform state."
  sensitive   = true
}


variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied to directly managed resources."
}


variable "secret_recovery_window_in_days" {
  type        = number
  default     = 30
  description = "Recovery window for the legacy unmanaged connection secret."
}

# selected_config is mandatory when more than one configuration is present.
# Cross-input checks are enforced by the database lifecycle preconditions.
