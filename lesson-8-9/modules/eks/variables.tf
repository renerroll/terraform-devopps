variable "region" {
  description = "AWS region for EKS-based CI/CD infrastructure (e.g. eu-north-1)"
  default     = "eu-north-1"
}

variable "cluster_name" {
  description = "Name of the EKS cluster to be used for Jenkins, Kaniko and Argo CD"
  default     = "lesson-7-cluster"
}

variable "subnet_ids" {
  description = "List of subnet IDs for EKS control plane and worker nodes"
  type        = list(string)
}

variable "node_group_name" {
  description = "Name of the managed node group for EC2 worker nodes"
  default     = "ci-cd-node-group"
}

variable "instance_type" {
  description = "EC2 instance type used for Jenkins and pipeline workloads"
  default     = "t3.medium"
}

variable "desired_size" {
  description = "Desired number of EC2 worker nodes to handle CI/CD tasks"
  default     = 2
}

variable "max_size" {
  description = "Maximum number of worker nodes to allow autoscaling"
  default     = 3
}

variable "min_size" {
  description = "Minimum number of worker nodes in the node group"
  default     = 1
}
