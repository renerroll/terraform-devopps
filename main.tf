terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
  }
}

provider "aws" {
  region = var.region
}


# module "s3_backend" {
#   source      = "./modules/s3-backend"            # Path to the S3 module
#   bucket_name = "terraform-state-bucket-alx"      # Name of the S3 bucket
#   table_name  = "terraform-locks"                 # Name of the DynamoDB table
# }

module "vpc" {
  source              = "./modules/vpc"                                       # Path to the VPC module
  vpc_name            = "vpc-alx"                                             # Name of the VPC
  vpc_cidr_block      = "10.0.0.0/16"                                         # CIDR block for the VPC
  public_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]         # CIDR blocks for Public subnets
  private_subnets     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]         # CIDR blocks for Private subnets
  availability_zones  = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]            # Availability zones
}

module "ecr" {
  source                  = "./modules/ecr"       # Path to the module
  ecr_repository_name     = "ecr-alx"             # Name of the ECR repository
  scan_on_push            = true                  # Whether to scan the image for vulnerabilities on push
  force_delete            = true                  # Whether to delete the repository along with its images
  image_tag_mutability    = "MUTABLE"             # Allow/disallow overwriting tags (MUTABLE/IMMUTABLE)
  image_retention_count   = 30                    # Number of images to retain before deleting older ones
}

module "eks" {
  source          = "./modules/eks"
  cluster_name    = "eks-cluster-alx"             # Cluster name
  eks_ui_username = "root"
  subnet_ids      = module.vpc.public_subnets     # Subnet IDs
  instance_type   = "t3.medium"                   # Instance type
  capacity_type   = "ON_DEMAND"                   # Instance capacity type
  ami_type        = "AL2023_x86_64_STANDARD"      # AMI type
  desired_size    = 2                             # Desired number of nodes
  max_size        = 3                             # Maximum number of nodes
  min_size        = 2                             # Minimum number of nodes
}

data "aws_eks_cluster" "eks" {                    # дозволяє Terraform отримати інформацію про створений кластер EKS
  name       = module.eks.eks_cluster_name
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "eks" {               # повертає IAM- токен, необхідний для автентифікації Helm до Kubernetes API
  name       = module.eks.eks_cluster_name
  depends_on = [module.eks]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.eks.endpoint          #  адреса API сервера Kubernetes
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)   # використовується для встановлення TLS-з’єднання
    token                  = data.aws_eks_cluster_auth.eks.token        #  дає Helm змогу автентифікуватися від імені AWS користувача (можна працювати з кластером повністю через Terraform, без ручного логіна )
  }
}

module "monitoring" {
  source = "./modules/monitoring"
  namespace     = "monitoring"
  depends_on = [
    module.eks
  ]
  providers = {
    helm = helm
    kubernetes = kubernetes
  }
}

module "jenkins" {
  source            = "./modules/jenkins"
  cluster_name      = module.eks.eks_cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
  github_pat        = var.github_pat
  github_user       = var.github_user
  github_repo_url   = var.github_repo_url
  github_branch     = var.github_branch
  jenkinsfile_dir  = var.jenkinsfile_dir

  depends_on = [module.eks]
  providers = {
    helm       = helm                   # підключає Helm-провайдер до Kubernetes через kubeconfig
    kubernetes = kubernetes
  }
}

module "argo_cd" {
  source        = "./modules/argo_cd"
  namespace     = "argocd"
  chart_version = "5.46.4"
  github_pat        = var.github_pat
  github_user       = var.github_user
  github_repo_url   = var.github_repo_url
  github_branch     = var.github_branch
  depends_on    = [module.eks]
}

module "rds" {
  source = "./modules/rds"

  name                       = "django-db"
  use_aurora                 = true
  aurora_instance_count      = 2
  vpc_cidr_block             = module.vpc.vpc_cidr_block

  # --- Aurora-only ---
  engine_cluster             = "aurora-postgresql"
  engine_version_cluster     = "15.3"
  parameter_group_family_aurora = "aurora-postgresql15"

  # --- RDS-only ---
  engine                     = "postgres"
  engine_version             = "17.2"
  parameter_group_family_rds = "postgres17"

  # Common
  instance_class             = "db.t3.medium"
  allocated_storage          = 20
  db_name                    = "django_db"
  username                   = "django_user"
  password                   = "admin123"
  subnet_private_ids         = module.vpc.private_subnets
  subnet_public_ids          = module.vpc.public_subnets
  publicly_accessible        = true
  vpc_id                     = module.vpc.vpc_id
  multi_az                   = true
  backup_retention_period    = 7
  parameters = {
    max_connections              = "200"
    log_min_duration_statement   = "500"
  }

  tags = {
    Environment = "dev"
    Project     = "django_db"
  }
  depends_on = [
    module.vpc
  ]

}


