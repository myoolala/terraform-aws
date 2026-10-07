# main.tf

# Data sources for AWS managed rule groups

data "aws_wafv2_rule_group" "mg" {
  for_each    = var.managed_rule_groups
  name        = each.value.name
  vendor_name = each.value.vendor
  scope       = var.scope
}

# IP Set resources

resource "aws_wafv2_ip_set" "ip" {
  for_each           = var.ip_sets
  name               = each.value.name
  scope              = var.scope
  ip_address_version = "IPV4"
  addresses          = each.value.addresses
}

# Web ACL

resource "aws_wafv2_web_acl" "this" {
  name           = var.name
  scope          = var.scope
  default_action = var.default_action == "ALLOW" ? { allow = {} } : { block = {} }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = var.name
    sampled_requests_enabled   = true
  }

  dynamic "rule" {
    for_each = local.rule_definitions
    content {
      name     = rule.value.name
      priority = rule.value.priority
      action   = rule.value.type == "ip_set" ? (rule.value.action == "ALLOW" ? { allow = {} } : { block = {} }) : (var.default_action == "ALLOW" ? { allow = {} } : { block = {} })
      statement {
        dynamic "rule_group_reference_statement" {
          for_each = rule.value.type == "managed" ? [1] : []
          content {
            arn            = data.aws_wafv2_rule_group.mg[rule.value.index].arn
            excluded_rules = rule.value.excluded_rules
          }
        }
        dynamic "ip_set_reference_statement" {
          for_each = rule.value.type == "ip_set" ? [1] : []
          content {
            arn = aws_wafv2_ip_set.ip[rule.value.index].arn
          }
        }
      }
    }
  }
}

# Web ACL association with ALB if provided

resource "aws_wafv2_web_acl_association" "this" {
  count        = var.alb_arn == null ? 0 : 1
  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.this.arn
}

# Locals for rule ordering

locals {
  rule_definitions = concat(
    [for idx, mg in var.managed_rule_groups : {
      type           = "managed"
      index          = idx
      priority       = idx + 1
      name           = mg.name
      excluded_rules = mg.excluded_rules
    }],
    [for idx, ip in var.ip_sets : {
      type     = "ip_set"
      index    = idx
      priority = length(var.managed_rule_groups) + idx + 1
      name     = ip.name
      action   = ip.action
    }]
  )
}

