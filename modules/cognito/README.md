<!-- BEGIN_TF_DOCS -->
# Cognito

Creates a Cognito User Pool and associated resources for a cognito based application

Example
```hcl
module "cognito" {
  source = "github.com/myoolala/terraform-aws/modules//cognito"

  name = "base-test"
  groups = [{
    name        = "test-1"
    description = "test-1"
    }, {
    name        = "test-2"
    description = "test-2"
    }, {
    name        = "test-3-no-role"
    description = "test-3"
  }]
  client_config = {
    name                                 = "test-for-the-test"
    callback_urls                        = ["https://example.com"]
    allowed_oauth_flows_user_pool_client = true
    allowed_oauth_flows                  = ["code", "implicit"]
    allowed_oauth_scopes                 = ["email", "openid"]
    supported_identity_providers         = ["COGNITO"]
  }
}
```

[More examples found here](../../tests/cognito)

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Requirements

No requirements.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Name for the Cognito User Pool | `string` | n/a | yes |
| <a name="input_client_config"></a> [client\_config](#input\_client\_config) | Configuration for the client if there is one | <pre>object({<br/>    name                                 = string<br/>    callback_urls                        = list(string)<br/>    allowed_oauth_flows_user_pool_client = optional(bool, true)<br/>    allowed_oauth_flows                  = list(string)<br/>    allowed_oauth_scopes                 = list(string)<br/>    supported_identity_providers         = list(string)<br/>  })</pre> | `null` | no |
| <a name="input_domain"></a> [domain](#input\_domain) | Domain to add to the pool if there is one. If you want a FQDN, leave null and manually create | `string` | `null` | no |
| <a name="input_groups"></a> [groups](#input\_groups) | List of groups to create along side the Cognito User Pool | <pre>list(object({<br/>    name        = string<br/>    description = string<br/>    precidence  = optional(number, 100)<br/>    role_arn    = optional(string, null)<br/>    # permissions = optional(string, null)<br/>  }))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Default tags to apply to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_client_id"></a> [client\_id](#output\_client\_id) | n/a |
| <a name="output_client_secret"></a> [client\_secret](#output\_client\_secret) | n/a |
| <a name="output_pool_arn"></a> [pool\_arn](#output\_pool\_arn) | ARN of the created user pool |
| <a name="output_pool_id"></a> [pool\_id](#output\_pool\_id) | n/a |  
<!-- END_TF_DOCS -->