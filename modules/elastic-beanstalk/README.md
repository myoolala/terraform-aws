# Elastic Beanstalk Module

This module provisions an AWS Elastic Beanstalk application, an application version, and an environment.

## Features
- Deploys Node.js or .NET applications via bundled ZIP archives.
- Supports local source bundles (auto‑uploaded to a new or existing S3 bucket).
- Optionally creates an S3 bucket for the bundle.
- Exposes convenient outputs for downstream modules.

## Usage
```hcl
module "eb" {
  source = "module/elastic-beanstalk"

  application_name          = "my-app"
  solution_stack_name       = "64bit Amazon Linux 2 v3.3.6 running Node.js 16"
  environment_name          = "prod"
  application_version_label = "v1"

  s3_bucket = "my-bucket"
  s3_key    = "my-app.zip"

  tags = {
    Environment = "Production"
  }
}
```

## Inputs
| Variable | Description | Type | Default |
|----------|-------------|------|---------|
| application_name | Name of the Elastic Beanstalk application. | string | N/A |
| solution_stack_name | Elastic Beanstalk solution stack. | string | N/A |
| environment_name | Name of the environment; defaults to `application_name`. | string | null |
| application_version_label | Label for the application version. | string | timestamped |
| source_code_path | Path to local source for an auto‑uploaded bundle. | string | null |
| s3_bucket | S3 bucket containing the bundle. | string | null |
| s3_key | S3 key of the bundle. | string | null |
| create_bucket | Create a new bucket when uploading a local bundle. | bool | true |
| tags | Map of tags. | map(string) | {} |

## Outputs
- `application_name`
- `environment_name`
- `application_version_label`
- `s3_bucket`
- `s3_key`

