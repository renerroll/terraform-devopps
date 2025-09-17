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
  region = "eu-central-1"
}

module "vpc" {
  source              = "./modules/vpc"          
  vpc_cidr_block      = "10.0.0.0/16"            
  public_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]       
  private_subnets     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]       
  availability_zones  = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]          
  vpc_name            = "vpc-lesson-8-9"             
}

# Підключаємо модуль ECR
module "ecr" {
  source           = "./modules/ecr"
  repository_name  = "lesson-8-9-ecr-818682288271"
}

module "eks" {
  source          = "./modules/eks"          
  cluster_name    = "eks-cluster-demo-lesson-8-9"            
  subnet_ids      = module.vpc.public_subnets     
  instance_type   = "t3.medium"                   
  desired_size    = 1                             
  max_size        = 2                             
  min_size        = 1                             
}

data "aws_eks_cluster_auth" "eks" {
  name = var.cluster_name
}

provider "helm" {
  kubernetes = {
    host                   = module.eks.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.eks_cluster_ca_data)
    token                  = data.aws_eks_cluster_auth.eks.token
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
  depends_on        = [module.eks]
  providers         = {
    helm       = helm
    kubernetes = kubernetes
  }
}

provider "kubernetes" {
  host                   = module.eks.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.eks_cluster_ca_data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

module "argo_cd" {
  source        = "./modules/argo_cd"
  namespace     = "argocd"
  chart_version = "5.46.4"
  depends_on    = [module.eks]
}

module "rds" {
  source = "./modules/rds"

  name                       = "myapp-db"
  use_aurora                 = false
  aurora_instance_count      = 2

  # Only if use_aurora = false
  engine                     = "postgres"
  engine_version             = "15.4"
  parameter_group_family_rds = "postgres15"

  # Common
  instance_class             = "db.t3.micro"
  allocated_storage          = 20
  db_name                    = "myapp"
  username                   = "django_user"
  password                   = "pass9764gd"
  port                       = 5432
  vpc_id                     = module.vpc.vpc_id
  subnet_private_ids         = module.vpc.private_subnets
  subnet_public_ids          = module.vpc.public_subnets
  publicly_accessible        = false
  multi_az                   = false
  backup_retention_period    = 7

  parameters = {
    max_connections = "200"
    log_min_duration_statement = "500"
  }

  tags = {
    Environment = "dev"
    Project     = "lesson-8-9"
  }
}


