###########################################################################
###############                   Required                  ###############
###########################################################################
variable "name" {
  type        = string
  description = "Name to apply to the VPC for reference"
}

###########################################################################
###############                 Not Required                ###############
###########################################################################
variable "ipv4_cidr" {
  type        = string
  description = "IPV4 CIDR for the VPC"
}

variable "ipv6_conf" {
  type = object({
    border_group = string
  })
  description = "Netmask length for a public ipv6 config. 44 to 60 in increments of 4"
  default = null
}

variable "secondary_ipv4_cidrs" {
  type = list(string)
  default = []
  description = "Additional IPV4 CIDR's to add to the vpc"
}

variable "secondary_ipv6_cidrs" {
  type = list(string)
  default = []
  description = "Additional IPV6 CIDR's to add to the vpc"
}

variable "instance_tenancy" {
  type = string
  description = "Desired Tenancy for the vpc"
  default = "default"
}

variable "ingress_subnets" {
  type = list(object({
    ipv4_cidr = optional(string, null)
    a_record_on_launch = optional(bool, false)
    ipv6_block_size = optional(number, null)
    ipv6_block = optional(number, null)
    ipv6_native = optional(bool, false)
    aaaa_record_on_launch = optional(bool, false)
    enable_dns64 = optional(bool, false)
    az = string
    nat = optional(bool, false)
  }))
  description = "List of ingress subnets to create for the vpc. These CIDRs should be small"
  default = []
}

variable "compute_subnets" {
  type = list(object({
    ipv4_cidr = optional(string, null)
    a_record_on_launch = optional(bool, false)
    ipv6_block_size = optional(number, null)
    ipv6_block = optional(number, null)
    ipv6_native = optional(bool, false)
    aaaa_record_on_launch = optional(bool, false)
    enable_dns64 = optional(bool, false)
    az = string
  }))
  description = "List of compute subnets to create for the vpc"
  default = []
}

variable "other_subnets" {
  type = map(list(object({
      ipv4_cidr = optional(string, null)
      a_record_on_launch = optional(bool, false)
      ipv6_block_size = optional(number, null)
      ipv6_block = optional(number, null)
      ipv6_native = optional(bool, false)
    aaaa_record_on_launch = optional(bool, false)
      enable_dns64 = optional(bool, false)
      az = string
    })))
  description = "List of other subnets to create for the vpc, like db subnets or endpoint subnets"
  default = {}
}

variable "public" {
  type = bool
  description = "Make the vpc accessible from the internet"
  default = false
}

variable "nat_azs" {
  type = list(string)
  description = "List of AZ's to deploy nat gateways to if the vpc is public and has compute subnets"
  default = []
}

variable "enable_dns_support" {
  type = bool
  description = "Enabled DNS support in the vpc"
  default = true
}

variable "enable_dns_hostnames" {
  type = bool
  description = "Enabled DNS hostnames in the vpc"
  default = true
}