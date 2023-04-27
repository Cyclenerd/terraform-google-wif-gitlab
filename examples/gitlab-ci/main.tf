# Create Workload Identity Pool Provider for GitLab
module "gitlab-wif" {
  source     = "Cyclenerd/wif-gitlab/google"
  version    = "~> 1.0.0"
  project_id = var.project_id
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
  version    = "~> 1.0.0"
  project_id = var.project_id
  pool_name  = module.gitlab-wif.pool_name
  account_id = google_service_account.gitlab.account_id
  repository = var.gitlab_repository
  depends_on = [google_service_account.gitlab]
}

# Get the Workload Identity Pool Provider resource name for GitLab CI configuration
output "gitlab-workload-identity-provider" {
  description = "The Workload Identity Provider resource name"
  value       = module.gitlab-wif.provider_name
}