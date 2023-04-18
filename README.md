# Google Cloud Workload Identity for GitLab

[![Bagde: Google Cloud](https://img.shields.io/badge/Google%20Cloud-%234285F4.svg?logo=google-cloud&logoColor=white)](https://github.com/Cyclenerd/terraform-google-wif-gitlab#readme)
[![Badge: Terraform](https://img.shields.io/badge/Terraform-%235835CC.svg?logo=terraform&logoColor=white)](https://github.com/Cyclenerd/terraform-google-wif-gitlab#readme)
[![Bagde: CI](https://github.com/Cyclenerd/terraform-google-wif-gitlab/actions/workflows/ci.yml/badge.svg)](https://github.com/Cyclenerd/terraform-google-wif-gitlab/actions/workflows/ci.yml)
[![Bagde: GitHub](https://img.shields.io/github/license/cyclenerd/terraform-google-wif-gitlab)](https://github.com/Cyclenerd/google-cloud-pricing-cost-calculator/blob/master/LICENSE)

This Terraform module creates a Workload Identity Pool and Provider for GitLab.

Service account keys are a security risk if compromised.
Avoid service account keys and instead use the [Workload Identity Federation](https://cloud.google.com/iam/docs/configuring-workload-identity-federation).
For more information about Workload Identity Federation and how to best authenticate service accounts on Google Cloud, please see my GitHub repo [Cyclenerd/google-workload-identity-federation](https://github.com/Cyclenerd/google-workload-identity-federation#readme).

> There is also a ready-to-use Terraform module for [GitHub](https://github.com/Cyclenerd/terraform-google-wif-github#readme).

## Example

Create Workload Identity Pool and Provider:

```hcl
# Create Workload Identity Pool Provider for GitLab
module "gitlab-wif" {
  source     = "Cyclenerd/wif-gitlab/google"
  version    = "1.0.0"
  project_id = "your-project-id"
}

# Get the Workload Identity Pool Provider resource name for GitLab CI configuration
output "gitlab-workload-identity-provider" {
  description = "The Workload Identity Provider resource name"
  value       = module.gitlab-wif.provider_name
}
```

> An example of a working GitLab CI configuration (`.gitlab-ci.yml`) can be found [here](https://gitlab.com/Cyclenerd/google-workload-identity-federation-for-gitlab/-/blob/master/.gitlab-ci.yml).

Allow service account to login via Workload Identity Provider and limit login only from the GitLab repository (project path) `octo-org/octo-repo`:

```hcl
# Get existing service account for GitLab CI
data "google_service_account" "gitlab" {
  project    = "your-project-id"
  account_id = "existing-account-for-gitlab-ci"
}

# Allow service account to login via WIF and only from GitLab repository (project path)
module "gitlab-service-account" {
  source     = "Cyclenerd/wif-service-account/google"
  version    = "1.0.0"
  project_id = "your-project-id"
  pool_name  = module.gitlab-wif.pool_name
  account_id = data.google_service_account.gitlab.account_id
  repository = "octo-org/octo-repo"
}
```

> Terraform module [`Cyclenerd/wif-service-account/google`](https://github.com/Cyclenerd/terraform-google-wif-service-account) is used.

👉 [**More examples**](https://github.com/Cyclenerd/terraform-google-wif-gitlab/tree/master/examples)

## OIDC Token Attribute Mapping

Attribute mapping:

| Attribute              | Claim                                                 |
|------------------------|-------------------------------------------------------|
| `google.subject`       | `assertion.sub`                                       |
| `attribute.sub`        | `assertion.sub`                                       |
| `attribute.actor`      | `assertion.actor`                                     |
| `attribute.repository` | `assertion.project_path` (not `assertion.repository`) |

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 4.61.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_audiences"></a> [allowed\_audiences](#input\_allowed\_audiences) | Workload Identity Pool Provider allowed audiences | `string` | `"https://gitlab.com"` | no |
| <a name="input_issuer_uri"></a> [issuer\_uri](#input\_issuer\_uri) | Workload Identity Pool Provider issuer URI | `string` | `"https://gitlab.com"` | no |
| <a name="input_pool_description"></a> [pool\_description](#input\_pool\_description) | Workload Identity Pool description | `string` | `"Workload Identity Pool for GitLab (Terraform managed)"` | no |
| <a name="input_pool_disabled"></a> [pool\_disabled](#input\_pool\_disabled) | Workload Identity Pool disabled | `bool` | `false` | no |
| <a name="input_pool_display_name"></a> [pool\_display\_name](#input\_pool\_display\_name) | Workload Identity Pool display name | `string` | `"gitlab.com"` | no |
| <a name="input_pool_id"></a> [pool\_id](#input\_pool\_id) | Workload Identity Pool ID | `string` | `"gitlab-com"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the project | `string` | n/a | yes |
| <a name="input_provider_description"></a> [provider\_description](#input\_provider\_description) | Workload Identity Pool Provider description | `string` | `"Workload Identity Pool Provider for GitLab (Terraform managed)"` | no |
| <a name="input_provider_disabled"></a> [provider\_disabled](#input\_provider\_disabled) | Workload Identity Pool Provider disabled | `bool` | `false` | no |
| <a name="input_provider_display_name"></a> [provider\_display\_name](#input\_provider\_display\_name) | Workload Identity Pool Provider display name | `string` | `"gitlab.com OIDC"` | no |
| <a name="input_provider_id"></a> [provider\_id](#input\_provider\_id) | Workload Identity Pool Provider ID | `string` | `"gitlab-com-oidc"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_pool_id"></a> [pool\_id](#output\_pool\_id) | Identifier for the pool |
| <a name="output_pool_name"></a> [pool\_name](#output\_pool\_name) | The resource name for the pool |
| <a name="output_pool_state"></a> [pool\_state](#output\_pool\_state) | State of the pool |
| <a name="output_provider_id"></a> [provider\_id](#output\_provider\_id) | Identifier for the provider |
| <a name="output_provider_name"></a> [provider\_name](#output\_provider\_name) | The resource name of the provider |
| <a name="output_provider_state"></a> [provider\_state](#output\_provider\_state) | State of the provider |
<!-- END_TF_DOCS -->

## License

All files in this repository are under the [Apache License, Version 2.0](LICENSE) unless noted otherwise.
