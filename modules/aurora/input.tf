variable "cluster_identifier" {
  type = string
  default = "aurora-test"
}

variable "engine" {
  type = string
  default = "aurora-postgresql"
}

variable "engine_version" {
  type = string
  default = "15.2"
}

variable "database_name" {
  type = string
  default = "testdb"
}

variable "master_username" {
  type = string
  default = "admin"
}

variable "master_password" {
  type = string
  default = "Password123!"
}

variable "db_subnet_group_name" {
  type = string
  default = ""
}

variable "vpc_security_group_ids" {
  type = list(string)
  default = []
}

variable "port" {
  type = number
  default = 5432
}

variable "storage_encrypted" {
  type = bool
  default = false
}

variable "kms_key_id" {
  type = string
  default = ""
}

variable "backup_retention_period" {
  type = number
  default = 1
}

variable "preferred_backup_window" {
  type = string
  default = "02:00-03:00"
}

variable "iam_database_authentication_enabled" {
  type = bool
  default = false
}

variable "apply_immediately" {
  type = bool
  default = true
}

variable "tags" {
  type = map(string)
  default = {
    Environment = "test"
  }
}

variable "instances" {
  type = map(object({
    identifier = string
    instance_class = string
    publicly_accessible = bool
    promotion_tier = number
    availability_zone = string
    tags = map(string)
  }))
  default = {
    test = {
      identifier  = "aurora-test-instance"
      instance_class = "db.t3.micro"
      publicly_accessible = false
      promotion_tier = 1
      availability_zone = "us-east-1a"
      tags = {}
    }
  }
}

variable "final_snapshot_seed" {
  type = string
  default = ""
}
