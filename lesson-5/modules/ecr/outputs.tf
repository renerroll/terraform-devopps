output "ecr_repository_url" {
  description = "URL репозиторію ECR"
  value       = aws_ecr_repository.this.repository_url
}
