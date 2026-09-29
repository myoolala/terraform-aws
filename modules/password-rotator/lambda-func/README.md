# Password Rotator Lambda

This Lambda function rotates credentials for **RDS databases** and **IAM user access keys** and stores the new secrets in either **Secrets Manager** or **SSM Parameter Store**.

## Supported Secrets

| Secret Type | Rotation Target | Store Mechanism |
|--------------|-----------------|-----------------|
| `RDS` | Master database password | `SecretsManager` or `SSM` |
| `IAM_USER_ACCESS_TOKEN` | IAM user access key | `SecretsManager` or `SSM` |

## Configuration

The function uses a priority‑ordered configuration source:

1. **Environment variables** – any process level environment variable is merged into the configuration.
2. **/opt/config.json** – the Lambda deployment package may include a JSON file in `/opt`.
3. **Defaults** – a small set of defaults is used when no overrides are supplied.

### Configuration JSON Schema

```json
{
  "secretStore": "secretsmanager|ssm",
  "passwordType": "RDS|IAM_USER_ACCESS_TOKEN",
  "secretStoreLocation": "arn:aws:secretsmanager:us-east-1:123456789012:secret:my-secret",
  "secretLocation": "arn:aws:secretsmanager:us-east-1:123456789012:secret:my-secret:1"
}
```

* `secretStore` – Where the new credentials are persisted.
* `passwordType` – Type of secret to rotate.
* `secretStoreLocation` – Destination ARN or SSM name.
* `secretLocation` – Source of the existing secret. For RDS it is the **ARN** of the DB instance or cluster; for IAM it is the IAM username.

### Environment Variable Overrides

| Variable | Description |
|----------|-------------|
| `SECRET_STORE` | e.g. `secretsmanager` or `ssm` |
| `PASSWORD_TYPE` | e.g. `RDS` |
| `SECRET_STORE_LOCATION` | e.g. `arn:aws:secretsmanager:…` |
| `SECRET_LOCATION` | e.g. the RDS ARN or IAM username |

## Usage

```bash
# Deploy the Lambda (outside the scope of this repo)
aws lambda create-function \
  --function-name PasswordRotator \
  --handler index.handler \
  --runtime nodejs20.x \
  --zip-file fileb://lambda.zip \
  --role arn:aws:iam::123456789012:role/lambda-role \
  --environment Variables={PASSWORD_TYPE=RDS,SECRET_STORE=secretsmanager,SECRET_STORE_LOCATION=arn:aws:secretsmanager:…}
```

The function can be triggered on schedule via EventBridge:

```json
{
  "schedule": "cron(0 0 * * ? *)",
  "target": {
    "arn": "arn:aws:lambda:us-east-1:123456789012:function:PasswordRotator",
    "id": "RotateSecrets"
  }
}
```

## Function API

The Lambda is invoked with an optional JSON payload containing `secret_type`
(e.g., `{"secret_type": "RDS"}`). If omitted, the type is taken from configuration.

All operations perform basic logging at `INFO` level; errors are logged and re‑thrown.
