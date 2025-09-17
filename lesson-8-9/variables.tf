variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = "eks-cluster-demo-nat"
}

variable "github_user" {
  type        = string
  description = "GitHub username for Jenkins credentials"
}

variable "github_pat" {
  type        = string
  description = "GitHub personal access token for Jenkins"
  sensitive   = true
}

variable "github_repo_url" {
  type        = string
  description = "GitHub repo URL for Jenkins seed job"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones for RDS and VPC"
  default     = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
}
