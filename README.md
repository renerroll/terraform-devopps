# Terraform AWS Infrastructure — Lesson 5

This project provisions basic AWS infrastructure using Terraform with modular structure and remote state backend.

## 📁 Project Structure

```
lesson-5/
├── backend.tf             # S3 + DynamoDB backend configuration
├── main.tf                # Module connections
├── modules/
│ ├── s3-backend/          # Remote state backend (S3 + DynamoDB)
│ ├── vpc/                 # Network infrastructure
│ └── ecr/                 # Docker image repository (ECR)
```

## ⚙️ Terraform Commands

```bash
terraform init
terraform plan
terraform apply
terraform destroy
```