# rotate-smtp-credentials

This module rotates IAM user credentials used for SMTP access and stores the new credentials in either AWS SSM Parameter Store or AWS Secrets Manager. It uses the generic `credential-rotator` module for Lambda packaging and deployment.

## Usage

```hcl
module "rotate_smtp" {
  source          = "../modules/rotate-smtp-credentials"
  name            = "tf-smtp-rotator"
  iam_user        = "example-user"
  ssm_parameter   = "/smtp/credentials"
  sns_topic       = "arn:aws:sns:region:account-id:topic"
}
```

## Variables

See `input.tf` for the full variable list.

## Outputs

See `output.tf`.
