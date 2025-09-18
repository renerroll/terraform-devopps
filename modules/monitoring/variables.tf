variable "release_name" {
  description = "Helm release name"
  type    = string
  default = "kube-prometheus-stack"
}

variable "namespace" {
  description = "Kubernetes namespace for monitoring stack"
  type    = string
  default = "monitoring"
}

variable "chart_version" {
  description = "Helm chart version"
  type    = string
  default = "75.10.0"
}

variable "repository" {
  description = "Prometeus repository"
  type        = string
  default = "https://prometheus-community.github.io/helm-charts"
}