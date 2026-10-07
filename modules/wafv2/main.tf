# main.tf

# IP Set resources

resource "aws_wafv2_ip_set" "ip" {
  for_each           = { for idx, ip in var.ip_sets : idx => ip }
  name               = each.value.name
  scope              = var.scope
  ip_address_version = "IPV4"
  addresses          = each.value.addresses
}

# Web ACL

resource "aws_wafv2_web_acl" "this" {
  name  = var.name
  scope = var.scope

  dynamic "default_action" {
    for_each = var.default_action == "ALLOW" ? [1] : []
    content {
      allow {}
    }
  }

  dynamic "default_action" {
    for_each = var.default_action == "BLOCK" ? [1] : []
    content {
      block {}
    }
  }

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

      # IP set actions
      dynamic "action" {
        for_each = rule.value.type == "ip_set" && rule.value.action == "ALLOW" ? [1] : []

        content {
          allow {}
        }
      }

      dynamic "action" {
        for_each = rule.value.type == "ip_set" && rule.value.action == "BLOCK" ? [1] : []

        content {
          block {}
        }
      }

      # Managed rule groups use override_action instead of action.
      # "none" means use the actions defined by the managed rule group.
      dynamic "override_action" {
        for_each = rule.value.type == "managed" ? [1] : []

        content {
          none {}
        }
      }

      statement {
        dynamic "managed_rule_group_statement" {
          for_each = rule.value.type == "managed" ? [1] : []

          content {
            name        = rule.value.name
            vendor_name = rule.value.vendor
          }
        }

        dynamic "ip_set_reference_statement" {
          for_each = rule.value.type == "ip_set" ? [1] : []

          content {
            arn = aws_wafv2_ip_set.ip[rule.value.index].arn
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
        metric_name                = "${var.name}-${rule.value.name}"
        sampled_requests_enabled   = var.sampled_requests_enabled
      }
    }
  }
}

# Web ACL association with ALB if provided

resource "aws_wafv2_web_acl_association" "this" {
  count = var.alb_arn == null ? 0 : 1

  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.this.arn
}

# Locals for rule ordering

locals {
  rule_definitions = concat(
    [for idx, mg in var.managed_rule_groups : {
      type     = "managed"
      index    = idx
      priority = idx + 1
      name     = mg.name
      vendor   = mg.vendor
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