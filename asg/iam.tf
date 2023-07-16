resource "aws_iam_role" "server_role" {
  name = var.name

  managed_policy_arns = var.managed_policies


  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
  })
}

resource "aws_iam_role_policy" "app_permissions" {
  count = var.permissions != null ? 1 : 0

  name = "app_permissions"
  role = aws_iam_role.server_role.id

  policy = var.permissions
}

resource "aws_iam_instance_profile" "server_role" {
  name = var.name
  role = aws_iam_role.server_role.name
}