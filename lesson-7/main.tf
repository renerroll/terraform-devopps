module "eks" {
  source       = "./modules/eks"
  cluster_name = "lesson-7-cluster"

  subnet_ids = [
    "subnet-0e78a27e38241576b",
    "subnet-052620cb6fba25ade",
    "subnet-05c54880f6c8b15f2"
  ]
}

module "ecr" {
  source          = "./modules/ecr"
  repository_name = "django-app"
}
