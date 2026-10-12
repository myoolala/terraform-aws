terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=6.38.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = ">=2.7.1"
    }
    random = {
      source  = "hashicorp/random"
      version = ">=3.7.2"
    }
  }
}