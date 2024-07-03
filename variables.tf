/**
 * Copyright 2023 Nils Knieling
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

# GOOGLE PROJECT

variable "project_id" {
  type        = string
  description = "The ID of the project"
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "Invalid project ID!"
  }
}

# IDENTITY POOL

variable "pool_id" {
  type        = string
  description = "Workload Identity Pool ID"
  default     = "gitlab-com"
  validation {
    condition = substr(var.pool_id, 0, 4) != "gcp-" && length(regex("([a-z0-9-]{4,32})", var.pool_id)) == 1
    error_message = join(" ", [
      "The 'pool_id' value should be 4-32 characters, and may contain the characters [a-z0-9-].",
      "The prefix 'gcp-' is reserved and can't be used in a pool ID."
    ])
  }
}

variable "pool_display_name" {
  type        = string
  description = "Workload Identity Pool display name"
  default     = "gitlab.com"
}

variable "pool_description" {
  type        = string
  description = "Workload Identity Pool description"
  default     = "Workload Identity Pool for GitLab (Terraform managed)"
}

variable "pool_disabled" {
  type        = bool
  description = "Workload Identity Pool disabled"
  default     = false
}

# IDENTITY POOL PROVIDER

variable "provider_id" {
  type        = string
  description = "Workload Identity Pool Provider ID"
  default     = "gitlab-com-oidc"
  validation {
    condition = substr(var.provider_id, 0, 4) != "gcp-" && length(regex("([a-z0-9-]{4,32})", var.provider_id)) == 1
    error_message = join(" ", [
      "The 'provider_id' value should be 4-32 characters, and may contain the characters [a-z0-9-].",
      "The prefix 'gcp-' is reserved and can't be used in a provider ID."
    ])
  }
}

variable "provider_display_name" {
  type        = string
  description = "Workload Identity Pool Provider display name"
  default     = "gitlab.com OIDC"
}

variable "provider_description" {
  type        = string
  description = "Workload Identity Pool Provider description"
  default     = "Workload Identity Pool Provider for GitLab (Terraform managed)"
}

variable "provider_disabled" {
  type        = bool
  description = "Workload Identity Pool Provider disabled"
  default     = false
}

variable "issuer_uri" {
  type        = string
  description = "Workload Identity Pool Provider issuer URI"
  default     = "https://gitlab.com"
}

variable "allowed_audiences" {
  type        = list(string)
  description = "Workload Identity Pool Provider allowed audiences"
  default     = ["https://gitlab.com"]
}

variable "attribute_mapping" {
  type        = map(string)
  description = "Workload Identity Pool Provider attribute mapping"
  default = {
    # Default attributes used in:
    # https://registry.terraform.io/modules/Cyclenerd/wif-service-account/google/latest
    "google.subject"       = "assertion.sub"          # Subject
    "attribute.sub"        = "attribute.sub"          # Subject
    "attribute.repository" = "assertion.project_path" # The repository (project path) from where the workflow is running
    # More
    # https://docs.gitlab.com/ee/ci/secrets/id_token_authentication.html#token-payload
    "attribute.aud"                   = "attribute.aud"                   # Audience
    "attribute.iss"                   = "attribute.iss"                   # Issuer
    "attribute.namespace_id"          = "assertion.namespace_id"          # Use this to scope to group or user level namespace by ID.
    "attribute.namespace_path"        = "assertion.namespace_path"        # Use this to scope to group or user level namespace by path.
    "attribute.project_id"            = "assertion.project_id"            # Use this to scope to project by ID.
    "attribute.project_path"          = "assertion.project_path"          # Use this to scope to project by path.
    "attribute.user_id"               = "assertion.user_id"               # ID of the user executing the job.
    "attribute.user_login"            = "assertion.user_login"            # Username of the user executing the job.
    "attribute.user_email"            = "assertion.user_email"            # Email of the user executing the job.
    "attribute.pipeline_id"           = "assertion.pipeline_id"           # ID of the pipeline.
    "attribute.pipeline_source"       = "assertion.pipeline_source"       # Pipeline source.
    "attribute.job_id"                = "assertion.job_id"                # ID of the job.
    "attribute.ref"                   = "assertion.ref"                   # Git ref for the job.
    "attribute.ref_type"              = "assertion.ref_type"              # Git ref type, either branch or tag.
    "attribute.ref_protected"         = "assertion.ref_protected"         # true if the Git ref is protected, false otherwise.
    "attribute.environment"           = "assertion.environment"           # Environment this job deploys to (introduced in GitLab 13.9).
    "attribute.environment_protected" = "assertion.environment_protected" # true if deployed environment is protected, false otherwise (introduced in GitLab 13.9).
    "attribute.deployment_tier"       = "assertion.deployment_tier"       # Deployment tier of the environment the job specifies. Introduced in GitLab 15.2.
    # 2024/04/04: runner_id removed. Error: The mapped attribute 'attribute.runner_id' must be of type STRING.
    #"attribute.runner_id"             = "assertion.runner_id"            # ID of the runner executing the job. Introduced in GitLab 16.0.
    "attribute.runner_environment" = "assertion.runner_environment" # The type of runner used by the job. Can be either gitlab-hosted or self-hosted. Introduced in GitLab 16.0.
    "attribute.sha"                = "assertion.sha"                # The commit SHA for the job. Introduced in GitLab 16.0.
  }
}

variable "attribute_condition" {
  type        = string
  description = "(Optional) Workload Identity Pool Provider attribute condition expression"
  default     = null
}