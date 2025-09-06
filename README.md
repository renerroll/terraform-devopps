# Lesson 7 — Kubernetes Deployment via EKS + Helm

This project provisions an EKS Kubernetes cluster using Terraform, builds and pushes a Django Docker image to AWS ECR, and deploys the application using Helm.

---

## Infrastructure Summary

- **EKS Cluster** — provisioned with Terraform into an existing VPC
- **IAM Role** — for cluster control plane
- **ECR Repository** — to store Docker image
- **Helm Chart** includes:
  - Deployment using image from ECR
  - ConfigMap with environment variables
  - LoadBalancer Service for external access
  - Horizontal Pod Autoscaler (HPA)

---
