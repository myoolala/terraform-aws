<!-- BEGIN_TF_DOCS -->
# SQS

Creates an SQS Queue with an optional KMS key configuration and policy configuration

## Creating a queue with the AWS provided KMS Key

```hcl
module "sqs" {
  source = "../../../modules/sqs"

  name         = "test-integration-queue"
  kms = {
    key = "alias/aws/sqs"
  }
}
```

[More examples can be found here](../../tests/sqs/)

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Requirements

No requirements.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Name to attach to the SQS Queue | `string` | n/a | yes |
| <a name="input_delay_seconds"></a> [delay\_seconds](#input\_delay\_seconds) | Time in seconds that the delivery of all messages in the queue will be delayed | `number` | `0` | no |
| <a name="input_kms"></a> [kms](#input\_kms) | KMS configuration for the Queue. Defaults to no encryption | <pre>object({<br/>    key             = string<br/>    deletion_window = optional(number, 14)<br/>    permissions     = optional(string, "")<br/>  })</pre> | <pre>{<br/>  "key": null<br/>}</pre> | no |
| <a name="input_max_message_size"></a> [max\_message\_size](#input\_max\_message\_size) | Limit of how many bytes a message can contain before Amazon SQS rejects it | `number` | `262144` | no |
| <a name="input_message_retention_seconds"></a> [message\_retention\_seconds](#input\_message\_retention\_seconds) | Number of seconds Amazon SQS retains a message | `number` | `345600` | no |
| <a name="input_policy"></a> [policy](#input\_policy) | Policy to attach to the topic if applicable | `string` | `null` | no |
| <a name="input_receive_wait_time_seconds"></a> [receive\_wait\_time\_seconds](#input\_receive\_wait\_time\_seconds) | Time for which a ReceiveMessage call will wait for a message to arrive (long polling) before returning | `number` | `0` | no |
| <a name="input_visibility_timeout_seconds"></a> [visibility\_timeout\_seconds](#input\_visibility\_timeout\_seconds) | Visibility timeout for the queue | `number` | `30` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kms_key"></a> [kms\_key](#output\_kms\_key) | KMS key id that was provided or created |
| <a name="output_kms_key_alias_arn"></a> [kms\_key\_alias\_arn](#output\_kms\_key\_alias\_arn) | KMS key Alias ARN that was created |
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | KMS key ARN that was created |
| <a name="output_sqs_arn"></a> [sqs\_arn](#output\_sqs\_arn) | ARN for the SQS Queue |  
<!-- END_TF_DOCS -->