mock_provider "aws" {}
mock_provider "random" {
  mock_resource "random_uuid" {
    defaults = { result = "b688bd80-4329-4c3b-88a9-a2fc197520b2" }
  }
  mock_resource "random_string" {
    defaults = { result = "TestOnlyPassword123" }
  }
}
mock_provider "null" {}

variables {
  name                        = "sqlserver-module-test"
  port                        = 1433
  create_sg                   = false
  multi_az                    = false
  manage_master_user_password = true
  vpc_config = {
    vpc_id  = "vpc-12345678"
    subnets = ["subnet-12345678", "subnet-87654321"]
    sg_ids  = ["sg-12345678"]
  }
  configs = {
    express2022 = {
      engine                 = "sqlserver-ex"
      engine_version         = "16.00.4215.2.v1"
      parameter_group_name   = "sqlserver-module-test-express2022"
      parameter_group_family = "sqlserver-ex-16.0"
      parameters             = [{ name = "rds.force_ssl", value = "1" }]
    }
  }
}

run "managed_credentials" {
  command = plan
  assert {
    condition     = length(random_string.default_pw) == 0 && length(module.admin_connection_info) == 0
    error_message = "Managed mode must not generate a second password or connection secret."
  }
  assert {
    condition     = aws_db_instance.db.password == null && aws_db_instance.db.db_name == null
    error_message = "SQL Server managed credentials must omit password and initial database name."
  }
  assert {
    condition     = aws_db_instance.db.deletion_protection && !aws_db_instance.db.delete_automated_backups
    error_message = "Recovery protections must be enabled by default."
  }
}

run "stage_upgrade_groups" {
  command = plan
  variables {
    selected_config = "express2019"
    configs = {
      express2019 = {
        engine                 = "sqlserver-ex"
        engine_version         = "15.00.4312.2.v1"
        parameter_group_name   = "sqlserver-module-test-express2019"
        parameter_group_family = "sqlserver-ex-15.0"
      }
      express2022 = {
        engine                 = "sqlserver-ex"
        engine_version         = "16.00.4215.2.v1"
        parameter_group_name   = "sqlserver-module-test-express2022"
        parameter_group_family = "sqlserver-ex-16.0"
      }
    }
  }
  assert {
    condition     = length(aws_db_parameter_group.params) == 2 && aws_db_instance.db.parameter_group_name == "sqlserver-module-test-express2019"
    error_message = "Both groups must exist while the selected configuration stays active."
  }
}

run "express_rejects_multi_az" {
  command = plan
  variables { multi_az = true }
  expect_failures = [aws_db_instance.db]
}

run "unmanaged_snapshot_has_no_invented_credentials" {
  command = plan
  variables {
    manage_master_user_password = false
    db_image                    = "existing-encrypted-snapshot"
  }
  assert {
    condition     = length(random_string.default_pw) == 0 && length(module.admin_connection_info) == 0 && output.admin_default_password == null && output.connection_secret == null
    error_message = "A snapshot must not get fabricated connection credentials."
  }
}

run "reject_managed_and_supplied_password" {
  command = plan
  variables { password = "TestOnlyPassword123!" }
  expect_failures = [aws_db_instance.db]
}

run "unmanaged_fresh_credentials" {
  command = plan
  variables { manage_master_user_password = false }
  assert {
    condition     = length(random_string.default_pw) == 1 && length(module.admin_connection_info) == 1
    error_message = "A fresh unmanaged instance must generate and publish matching credentials."
  }
}

run "module_created_security_group" {
  command = plan
  variables {
    create_sg = true
    vpc_config = {
      vpc_id               = "vpc-12345678"
      subnets              = ["subnet-12345678", "subnet-87654321"]
      ingress_sg_whitelist = ["sg-12345678"]
    }
  }
  assert {
    condition     = length(module.rds_sg) == 1
    error_message = "The optional security group must remain usable."
  }
}
