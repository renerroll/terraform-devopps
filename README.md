# Lesson 7 — EKS + ECR + Helm (Django)

This repository contains Terraform modules and a Helm chart to deploy a Django application to AWS EKS, store the Docker image in ECR, and manage runtime configuration with a ConfigMap.

Repository layout (relevant parts):

- `lesson-7/`
  - `main.tf` — module wiring for `eks` and `ecr`
  - `modules/eks/` — Terraform module that creates the EKS cluster and IAM roles
  - `modules/ecr/` — Terraform module that creates the ECR repository
  - `charts/django-app/` — Helm chart with deployment, service, configmap, HPA and `values.yaml`

## What this project provides

- Terraform module to create an EKS cluster (control plane + IAM roles). Note: add a node group or managed node group to run pods (example below).
- Terraform module to create an ECR repository and output the repository URL.
- A Helm chart (`lesson-7/charts/django-app`) which defines:
  - `Deployment` using the image from ECR and `envFrom: configMapRef`
  - `Service` of type `LoadBalancer`
  - `ConfigMap` for environment variables
  - `HorizontalPodAutoscaler` (v2) driven by CPU utilization

## Prerequisites

- AWS CLI configured with permissions to create EKS, ECR and IAM resources.
- Terraform v1.2+ installed and configured.
- kubectl and helm installed locally.
- Docker to build the image locally (or CI).

## Quick workflow (high level)

1. Provision infrastructure (EKS control plane and ECR repository) with Terraform.
2. Build Docker image and push to ECR.
3. Create or configure node group so the EKS cluster can run pods.
4. Configure kubeconfig and verify nodes.
5. Install Helm chart into the cluster.

## Detailed steps

1) Terraform apply (in `lesson-7/`):

```bash
cd lesson-7
terraform init
terraform plan
terraform apply -auto-approve
```

After apply, note the ECR repository URL (output `module.ecr.repository_url`) and EKS outputs (`cluster_name`, `cluster_endpoint`).

2) Build, tag and push Docker image to ECR (replace values):

```bash
# build
docker build -t django-app:latest ./django_docker_project

# login to ECR (replace region and account)
aws ecr get-login-password --region <aws-region> | docker login --username AWS --password-stdin <aws-account-id>.dkr.ecr.<aws-region>.amazonaws.com

# tag & push
docker tag django-app:latest <account>.dkr.ecr.<region>.amazonaws.com/django-app:latest
docker push <account>.dkr.ecr.<region>.amazonaws.com/django-app:latest
```

3) Add node group (if not present)

If your Terraform module does not create worker nodes, add an `aws_eks_node_group` resource in `lesson-7/modules/eks/` (example in notes) and apply.

4) Configure kubectl

```bash
aws eks --region <region> update-kubeconfig --name <cluster_name>
kubectl get nodes
```

5) Deploy Helm chart

Update `lesson-7/charts/django-app/values.yaml` with the pushed image repository and tag. Then:

```bash
helm install django-app lesson-7/charts/django-app --values lesson-7/charts/django-app/values.yaml
kubectl get deployments,svc,hpa
```

6) Verify

- Service should have an external IP (LoadBalancer) and proxy through Nginx (or directly if configured).
- HPA will scale pods based on CPU usage as configured in `values.yaml`.

## Example additions (node group & IAM)

Add to `lesson-7/modules/eks/eks.tf`:

```hcl
# example: managed node group
resource "aws_iam_role" "worker" {
  name = "${var.cluster_name}-worker-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{ Effect = "Allow", Principal = { Service = "ec2.amazonaws.com" }, Action = "sts:AssumeRole" }]
  })
}

resource "aws_iam_role_policy_attachment" "worker_attach" {
  role       = aws_iam_role.worker.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_eks_node_group" "workers" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "${var.cluster_name}-ng"
  node_role_arn   = aws_iam_role.worker.arn
  subnet_ids      = var.subnet_ids
  scaling_config { desired_size = 2 min_size = 2 max_size = 4 }
  instance_types = ["t3.medium"]
}
```

## Notes & next steps
- Secrets (DB passwords) should be stored in Kubernetes Secrets rather than ConfigMaps for production.
- Consider adding a CI workflow (GitHub Actions) to build & push images to ECR and run `helm upgrade --install`.
- Update `lesson-7/README.md` with the exact `repository_url` after Terraform apply, or automate via CI variables.

---

If you want, I can:
- add the example `aws_eks_node_group` and required IAM resources to the EKS module now, or
- create a GitHub Actions workflow to build/push the image and deploy the Helm chart automatically.
