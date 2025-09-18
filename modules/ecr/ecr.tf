# Creates an ECR repository
resource "aws_ecr_repository" "this" {
  name                 = var.ecr_repository_name    # Repository name
  image_tag_mutability = var.image_tag_mutability   # Allow/disallow tag overwrites (MUTABLE/IMMUTABLE)
  force_delete         = var.force_delete           # Allows deleting the repository along with images
  image_scanning_configuration {
    scan_on_push = var.scan_on_push                 # Whether to scan the image for vulnerabilities on push
  }
  tags = {
    Name        = var.ecr_repository_name
    Environment = "lesson-5"
  }
}


# ECR Repository Policy
resource "aws_ecr_repository_policy" "this" {
  repository = aws_ecr_repository.this.name   # Attach the policy to the repository

  policy = jsonencode({
    Version = "2012-10-17"                    # AWS IAM policy version
    Statement = [
      {
        Sid    = "AllowPullFromECR"           # Statement ID for pulling images
        Effect = "Allow"                      # Allow the action
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"   # ARN of the root user of the current account
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",       # Download layers
          "ecr:BatchGetImage",                # Get information about images
          "ecr:BatchCheckLayerAvailability"   # Check layer availability
        ]
      },
      {
        Sid    = "AllowPushToECR"             # Second rule: allow pushing images
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = [
          "ecr:PutImage",                     # Publish image
          "ecr:InitiateLayerUpload",          # Initiate layer upload
          "ecr:UploadLayerPart",              # Upload part of a layer
          "ecr:CompleteLayerUpload"           # Complete layer upload
        ]
      }
    ]
  })
}

# ECR Lifecycle Policy
resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name         # Attach the policy to the repository

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1                            # Rule priority (lower means higher priority)
        description  = "Keep only last ${var.image_retention_count} images"
        selection = {                               # Image selection criteria
          tagStatus   = "any"                       # Any tag
          countType   = "imageCountMoreThan"        # Count type — if the number of images exceeds the specified
          countNumber = var.image_retention_count   # Number of images to retain before deleting
        }
        action = {                                  # Action for selected images
          type = "expire"                           # Delete image (expire)
        }
      }
    ]
  })
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}   # data-источник, который возвращает информацию о текущем AWS-пользователе (включая account_id)