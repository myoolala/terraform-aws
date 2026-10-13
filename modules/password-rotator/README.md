<!-- BEGIN_TF_DOCS -->
# Password Rotator Lambda Service

This module packages a Node.js Lambda that rotates credentials stored in AWS Secrets Manager. The Lambda automatically fetches the current secret, generates new credentials, updates the secret, and optionally stores the new credentials via user‑defined hooks. It can be configured to run on a schedule or invoked manually.

## Hook System

Hooks are an optional JavaScript module exported as a default object located by default at `/opt/hooks.mjs` inside the Lambda runtime.
Each hook is an async function that may be called by the Lambda during its execution flow. The supported hooks are:

* `onStart()` – called before any work begins.
* `getCurrentCredentials()` – should return the current secret value.
* `generateCredentials()` – should return a new credential object.
* `updateCredentials(newCreds)` – used by the Lambda to update the secret; the function is called with the new credentials.
* `storeCredentials()` – called after a successful update; may persist the new credentials to an external system. Return true to indicate success.
* `revertCredentials()` – called if `storeCredentials()` fails; used to roll back changes.
* `onComplete()` – called after a successful run.
* `onFail(err)` – called if any step throws.

If a hook is omitted it is treated as a no‑op; the Lambda will continue with default behaviour. Hooks are useful when you need to keep an external system in sync, perform additional validation, or trigger notifications.

### Sample Hook File

```js
// /opt/hooks.mjs
export default {
  // Called before the Lambda starts the rotation process.
  onStart: async () => {
    console.log('Rotation starting');
  },

  // Retrieve the existing secret – could query an alternative store.
  getCurrentCredentials: async () => {
    // Return the current value; may be an object.
    return {};
  },

  // Generate a new password.
  generateCredentials: async () => {
    const password = Math.random().toString(36).slice(-12);
    return { password };
  },

  // Persist the updated secret – optional if the Lambda writes directly.
  updateCredentials: async (newCreds) => {
    // Perform any extra validation before the Lambda updates its own copy.
  },

  // After the secret has been updated, push the new credentials elsewhere.
  storeCredentials: async () => {
    // Return false to trigger a revert.
    return true;
  },

  // Called if storeCredentials fails.
  revertCredentials: async () => {
    console.log('Reverting secrets to previous state');
  },

  // After a successful run.
  onComplete: async () => {
    console.log('Rotation completed');
  },

  // Called if any hook throws an error.
  onFail: async (err) => {
    console.error('Rotation failed', err);
  },
};
```

## Example Usage

```hcl
module "password_rotator" {
  source  = "github.com/myorg/terraform-aws//modules/password-rotator"
  lambda_function_name = "rotate-credentials"
  schedule              = "rate(90 days)"          # Optional
  memory                = 256
  vpc_subnet_ids        = [aws_subnet.private.id]
  vpc_security_group_ids = [aws_security_group.lambda.id]
  lambda_layer_arn       = aws_lambda_layer_version.my_layer.arn
  permissions           = <<EOF
[
  {
    "Sid": "SecretsManagerExample",
    "Effect": "Allow",
    "Action": [
      "secretsmanager:GetSecretValue",
      "secretsmanager:UpdateSecret",
      "secretsmanager:PutSecretValue"
    ],
    "Resource": "*"
  }
]
EOF
  secrets = {
    arns     = [aws_secretsmanager_secret.my_secret.arn]
    kms_keys = []
  }
}
```

The module builds the Lambda zip, copies the `index.mjs` and `config.mjs` into the deployment archive, and attaches the optional layer, VPC settings, and IAM permissions.

## Parameters

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_lambda_function_name"></a> [lambda\_function\_name](#input\_lambda\_function\_name) | The name of the Lambda function to create. | `string` | n/a | yes |
| <a name="input_lambda_layer_arn"></a> [lambda\_layer\_arn](#input\_lambda\_layer\_arn) | Optional ARN of a Lambda layer to attach. | `string` | `null` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Memory allocation per runtime for the lambda function. | `number` | `128` | no |
| <a name="input_permissions"></a> [permissions](#input\_permissions) | Additional IAM policy permissions for the lambda role. Must be JSON encoded array of policy statements. | `any` | `null` | no |
| <a name="input_schedule"></a> [schedule](#input\_schedule) | Optional cron or rate expression to schedule automatic invocation of the lambda function. | `string` | `"rate(90 days)"` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | Secrets ARNs and associated KMS key ARNs the lambda will need access to | <pre>object({<br/>    arns     = list(string)<br/>    kms_keys = list(string)<br/>  })</pre> | <pre>{<br/>  "arns": [],<br/>  "kms_keys": []<br/>}</pre> | no |
| <a name="input_vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#input\_vpc\_security\_group\_ids) | Optional list of security group IDs for VPC configuration. | `list(string)` | `[]` | no |
| <a name="input_vpc_subnet_ids"></a> [vpc\_subnet\_ids](#input\_vpc\_subnet\_ids) | Optional list of subnet IDs for VPC configuration. | `list(string)` | `[]` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lambda_function_invoke_arn"></a> [lambda\_function\_invoke\_arn](#output\_lambda\_function\_invoke\_arn) | Invoke ARN of the created Lambda function. |
| <a name="output_lambda_function_name"></a> [lambda\_function\_name](#output\_lambda\_function\_name) | Name of the created Lambda function. |
| <a name="output_lambda_log_group"></a> [lambda\_log\_group](#output\_lambda\_log\_group) | Log group configuration created for the Lambda function. |
| <a name="output_lambda_role_arn"></a> [lambda\_role\_arn](#output\_lambda\_role\_arn) | ARN of the IAM role used by the Lambda function. |
| <a name="output_lambda_role_name"></a> [lambda\_role\_name](#output\_lambda\_role\_name) | The name of the IAM role used by the Lambda function. |
| <a name="output_lambda_security_group_ids"></a> [lambda\_security\_group\_ids](#output\_lambda\_security\_group\_ids) | List of security group IDs attached to the Lambda function if any. |

## Example Tests

See the test harness in `tests/password-rotator/` for comprehensive examples.
<!-- END_TF_DOCS -->