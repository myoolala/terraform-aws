module "vpc" {
  source = "../../../modules/vpc"

  name      = "private-vpc-test"
  ipv4_cidr = "172.31.0.0/16"
  ingress_subnets = [{
    ipv4_cidr = "172.31.0.0/27"
    az        = "us-east-1a"
    },
    {
      ipv4_cidr = "172.31.0.32/27"
      az        = "us-east-1b"
  }]
  compute_subnets = [{
    ipv4_cidr = "172.31.1.0/25"
    az        = "us-east-1a"
    },
    {
      ipv4_cidr = "172.31.1.128/25"
      az        = "us-east-1b"
  }]
}

module "secrets" {
  source = "../../../modules/secrets"

  secrets         = [{
    name = "testSecretInternalTrafficCert"
    value = "ImSoCerty"
  }]
  create_new_key  = true
  recovery_window = 0
}

module "fargate_service" {
  source = "../../../modules/fargate-service"

  service_name = "test-service"
  network = {
    vpc_id  = module.vpc.vpc_id
    subnets = module.vpc.compute_subnet_ids
  }
  cluster = {
    name   = "test-service"
    create = true
  }
  ecr = {
    create       = true
    scan_on_push = false
  }
  image_tag     = "latest"
  log_retention = 7
  env_vars = {

  }
  secrets = [{
    name = "testOtherNewBetterSecretOmg123"
    value = "TheKeyToLife"
    env_name = "SSL_KEY"
  }]
  existing_secrets = {
    task_def_mapping = [{
      name = "SSL_CERT"
      valueFrom = module.secrets.arn_map["testSecretInternalTrafficCert"]
    }]
    kms_key_arns = [module.secrets.kms_key]
  }

  desired_count = 0
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Environment = "tf-integration-test"
      Billing     = "tf-integration-test"
    }
  }
}