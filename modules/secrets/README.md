<!-- BEGIN_TF_DOCS -->
# SecretsManager

Creates a set of secrets in SecretsManager using a single KMS key. Then returns a variety of lists meant for simple integration with other services

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Requirements

No requirements.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_region"></a> [region](#input\_region) | Region for replicating the secret in | `string` | n/a | yes |
| <a name="input_create_new_key"></a> [create\_new\_key](#input\_create\_new\_key) | Create a new key to encrypt the secrets data with instead of using the provided key | `bool` | `true` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | Name of the kms key to associate with the secrets | `string` | `"alias/aws/secretsmanager"` | no |
| <a name="input_recovery_window"></a> [recovery\_window](#input\_recovery\_window) | Number of days, 0 to 30, to store a deleted secret in order to recover it | `number` | `7` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | Map of secrets to store in aws secrets manager | `list(map(string))` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn_map"></a> [arn\_map](#output\_arn\_map) | A mapping of the name of the secret mapped to its ARN |
| <a name="output_env_map"></a> [env\_map](#output\_env\_map) | A mapping of the secrets from the environment variable name to its ARN in SecretsManager |
| <a name="output_fargate_secrets"></a> [fargate\_secrets](#output\_fargate\_secrets) | A mapping of the secrets environment variable name to its value from to support integration with ECS |
| <a name="output_kms_key"></a> [kms\_key](#output\_kms\_key) | ARN of the kms key used to encrypt the secrets |
| <a name="output_secret_map"></a> [secret\_map](#output\_secret\_map) | A list of the name of the secret and its ARN |  
<!-- END_TF_DOCS -->