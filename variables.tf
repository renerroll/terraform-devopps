variable "region" {
  description = "AWS region for deployment"
  type        = string
  default     = "eu-west-1"
}

variable "github_pat" {
  description = "GitHub Personal Access Token"
  type        = string
  sensitive   = true
}

variable "github_user" {
  description = "GitHub username"
  type        = string
}

variable "github_repo_url" {
  description = "GitHub repository name"
  type        = string
}

variable "github_branch" {
  type        = string
  description = "GitHub branch name"
}

variable "jenkinsfile_dir" {
  description = "Application Jenkinsfile location"
  type        = string
}
