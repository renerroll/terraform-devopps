variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "oidc_provider_arn" {
  description = "OIDC provider ARN for IRSA"
  type        = string
}

variable "oidc_provider_url" {
  description = "OIDC provider URL for IRSA"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for deploying Jenkins"
  type        = string
  default     = "jenkins"
}

variable "github_user" {
  description = "GitHub username for Jenkins values.yaml"
  type        = string
}

variable "github_pat" {
  description = "GitHub Personal Access Token"
  type        = string
  sensitive   = true
}

variable "github_repo_url" {
  description = "URL to Helm chart GitHub repository"
  type        = string
}
