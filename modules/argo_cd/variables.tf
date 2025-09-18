variable "name" {
  description = "Name of the Helm release"
  type        = string
  default     = "argo-cd"
}

variable "namespace" {
  description = "K8s namespace для Argo CD"
  type        = string
  default     = "argocd"
}

variable "chart_version" {
  description = "Version of the Argo CD chart"
  type        = string
  default     = "5.46.4"
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
  description = "GitHub repository URL"
  type        = string
}

variable "github_branch" {
  description = "GitHub branch for Jenkins"
  type        = string
}