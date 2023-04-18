variable "project_id" {
  type        = string
  description = "The ID of the project"
}

variable "gitlab_account_id" {
  type        = string
  description = "The account id of the service account for GitLab CI"
}

variable "gitlab_repository" {
  type        = string
  description = "The GitLab repository (project path)"
}