output "eks_node_role_arn" {
  value = aws_iam_role.eks.arn
}

output "eks_cluster_ca_data" {
  description = "EKS cluster CA cert"
  value       = aws_eks_cluster.eks.certificate_authority[0].data
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.eks.endpoint
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.eks.name
}

output "oidc_provider_arn" {
  description = "OIDC provider ARN"
  value       = aws_iam_openid_connect_provider.oidc.arn
}

output "oidc_provider_url" {
  description = "OIDC provider URL"
  value       = aws_iam_openid_connect_provider.oidc.url
}
