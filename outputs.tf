#-------------Backend-----------------

# output "s3_bucket_name" {
#   description = "Name of the S3 bucket for storing Terraform state files"
#   value       = module.s3_backend.s3_bucket_name
# }
#
# output "s3_bucket_url" {
#   description = "URL of the S3 bucket for states"
#   value       = module.s3_backend.s3_bucket_url
# }
#
# output "dynamodb_table_name" {
#   description = "Name of the DynamoDB table for state locking"
#   value       = module.s3_backend.dynamodb_table_name
# }

#-------------VPC-----------------

output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = module.vpc.internet_gateway_id
}

#-------------ECR-----------------

output "repository_name" {
  description = "The name of the ECR repository"
  value       = module.ecr.repository_name
}

output "repository_url" {
  description = "The URL of the ECR repository (for push images)"
  value       = module.ecr.repository_url
}

output "repository_arn" {
  description = "The ARN of the ECR repository"
  value       = module.ecr.repository_arn
}

#-------------EKS-----------------

output "eks_cluster_endpoint" {
  description = "EKS API endpoint for connecting to the cluster"
  value       = module.eks.eks_cluster_endpoint
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.eks_cluster_name
}

output "eks_node_role_arn" {
  description = "IAM role ARN for EKS Worker Nodes"
  value       = module.eks.eks_node_role_arn
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "oidc_provider_url" {
  value = module.eks.oidc_provider_url
}

#-------------jenkins-----------------

output "jenkins_release" {
  value = module.jenkins.jenkins_release_name
}

output "jenkins_namespace" {
  value = module.jenkins.jenkins_namespace
}

#-------------argo_cd-----------------

output "argocd_server_service" {
  value       = module.argo_cd.argo_cd_server_service
}

output "admin_password" {
  value = module.argo_cd.admin_password
}

#-------------RDS-----------------

output "rds_endpoint" {
  value = module.rds.rds_endpoint
}

#-------------monitoring-----------------

output "prometheus_service_name" {
  value = module.monitoring.prometheus_service_name
}

output "grafana_service_name" {
  value = module.monitoring.grafana_service_name
}



