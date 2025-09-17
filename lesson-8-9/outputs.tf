output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnets
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = module.vpc.internet_gateway_id
}

output "ecr_repository_url" {
  description = "Full repository URL used for docker push/pull"
  value       = module.ecr.repository_url
}

output "ecr_repository_arn" {
  description = "ARN of the created ECR repository"
  value       = module.ecr.repository_arn
}

output "eks_cluster_endpoint" {
  description = "EKS API endpoint for connecting to the cluster"
  value       = module.eks.eks_cluster_endpoint
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.eks_cluster_name
}

output "eks_node_role_arn" {
  description = "IAM role ARN for EKS worker nodes"
  value       = module.eks.eks_node_role_arn
}

output "rds_endpoint" {
  value       = module.rds.endpoint
  description = "RDS endpoint hostname"
}

output "rds_port" {
  value       = module.rds.port
  description = "RDS port number"
}
