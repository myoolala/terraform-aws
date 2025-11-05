module "lambda" {
  source = "../../../modules/kms-key"

  description = "test"
  permissions = jsonencode({
    Statement = [
      {
        Action = "kms:*"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::637271283041:root"
        }
        Resource = "*"
        Sid      = "Test"
      },
      {
        Action = "kms:Encrypt"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::637271283041:root"
        }
        Resource = "*"
        Sid      = "Default"
      },
    ]
    Version = "2012-10-17"
  })
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