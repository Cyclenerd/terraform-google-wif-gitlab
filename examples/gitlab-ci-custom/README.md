# GitLab CI (Custom Domain)

The following example shows you how to configure Workload Identity Federation via Terraform IaC for a self-managed GitLab CI with a custom domain.

## Example

With this example the following steps are executed and configured:

1. Create Workload Identity Pool Provider for GitLab
1. Create new service account for GitLab CI
1. Allow login via Workload Identity Provider and limit login only from the GitLab repository (project path)
1. Output the Workload Identity Pool Provider resource name for GitLab CI configuration

> An example of a working GitLab CI configuration (`.gitlab-ci.yml`) can be found [here](https://gitlab.com/Cyclenerd/google-workload-identity-federation-for-gitlab/-/blob/master/.gitlab-ci.yml).

<!-- BEGIN_TF_DOCS -->

```hcl
# Create Workload Identity Pool Provider for self-managed GitLab installation
module "gitlab-custom-wif" {
  source                = "Cyclenerd/wif-gitlab/google"
  version               = "~> 1.0.0"
  project_id            = var.project_id
  allowed_audiences     = "https://gitlab.example.com"
  issuer_uri            = "https://gitlab.example.com"
  pool_id               = "gitlab-example-com"
  pool_display_name     = "gitlab.example.com"
  pool_description      = "Workload Identity Pool for self-managed GitLab (Terraform managed)"
  provider_id           = "gitlab-example-com-oidc"
  provider_display_name = "gitlab.example.com OIDC"
  provider_description  = "Workload Identity Pool Provider for self-managed GitLab (Terraform managed)"
}

# Create new service account for GitLab CI
resource "google_service_account" "gitlab" {
  project      = var.project_id
  account_id   = var.gitlab_account_id
  display_name = "GitLab CI (WIF)"
  description  = "Service Account for self-managed GitLab CI ${var.gitlab_repository} (Terraform managed)"
}

# Allow service account to login via WIF and only from GitLab repository (project path)
module "github-service-account" {
  source     = "Cyclenerd/wif-service-account/google"
  version    = "~> 1.0.0"
  project_id = var.project_id
  pool_name  = module.gitlab-custom-wif.pool_name
  account_id = google_service_account.gitlab.account_id
  repository = var.gitlab_repository
  depends_on = [google_service_account.gitlab]
}

# Get the Workload Identity Pool Provider resource name for GitLab CI configuration
output "gitlab-workload-identity-provider" {
  description = "The Workload Identity Provider resource name"
  value       = module.gitlab-custom-wif.provider_name
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_gitlab_account_id"></a> [gitlab\_account\_id](#input\_gitlab\_account\_id) | The account id of the service account for GitLab CI | `string` | n/a | yes |
| <a name="input_gitlab_repository"></a> [gitlab\_repository](#input\_gitlab\_repository) | The GitLab repository (project path) | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the project | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_gitlab-workload-identity-provider"></a> [gitlab-workload-identity-provider](#output\_gitlab-workload-identity-provider) | The Workload Identity Provider resource name |
<!-- END_TF_DOCS -->
