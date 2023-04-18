# Create Workload Identity Pool Provider for self-managed GitLab installation
module "gitlab-custom-wif" {
  source                = "Cyclenerd/wif-gitlab/google"
  version               = "1.0.0"
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
  description  = "Service Account for GitLab CI ${var.gitlab_repository} (Terraform managed)"
}

# Allow service account to login via WIF and only from GitLab repository (project path)
module "github-service-account" {
  source     = "Cyclenerd/wif-service-account/google"
  version    = "1.0.0"
  project_id = var.project_id
  pool_name  = module.gitlab-custom-wif.pool_name
  account_id = google_service_account.gitlab.account_id
  repository = var.gitlab_repository
}

# Get the Workload Identity Pool Provider resource name for GitLab CI configuration
output "gitlab-workload-identity-provider" {
  description = "The Workload Identity Provider resource name"
  value       = module.gitlab-custom-wif.provider_name
}