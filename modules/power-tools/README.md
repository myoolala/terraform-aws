<!-- BEGIN_TF_DOCS -->


## Example

Halp

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |

## Requirements

No requirements.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_build_runtime"></a> [build\_runtime](#input\_build\_runtime) | Version of Python to build the powertools layer with | `string` | `"python3.12"` | no |
| <a name="input_compatible_runtimes"></a> [compatible\_runtimes](#input\_compatible\_runtimes) | Allowed python versions to use | `list(string)` | <pre>[<br/>  "python3.6",<br/>  "python3.7",<br/>  "python3.8",<br/>  "python3.9",<br/>  "python3.10",<br/>  "python3.11",<br/>  "python3.12"<br/>]</pre> | no |
| <a name="input_layer_name"></a> [layer\_name](#input\_layer\_name) | Name to give the lambda layer | `string` | `null` | no |
| <a name="input_power_tools_version"></a> [power\_tools\_version](#input\_power\_tools\_version) | Version of power tools to use | `string` | `""` | no |

## Outputs

No outputs.  
<!-- END_TF_DOCS -->