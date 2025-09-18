# Microservice project - Terraform, Kubernetes, Helm, Jenkins, Argo CD, RDS, Aurora, Prometheus, Grafana

This project provide basic AWS infrastructure using Terraform with modular structure and remote state backend.

## Project Structure

```
├── backend.tf             # S3 + DynamoDB backend configuration
├── main.tf                # Main entry point to invoke modules
├── Jenkinsfile            # CI pipeline definition
├── django/                # Application for image building
├── modules/               # Terraform modules
│ ├── s3-backend/          # Remote state backend (S3 + DynamoDB) module
│ ├── vpc/                 # Network infrastructure (VPC) module
│ ├── rds/                 # RDS/Aurora database configuration
│ ├── ecr/                 # Docker image repository (ECR) module
│ ├── eks/                 # Kubernetes cluster (EKS) module
│ ├── monitoring/          # Prometheus and Grafana 
│ ├── jenkins/             # Jenkins Helm deployment + config
│ └── argo_cd/             # Argo CD Helm deployment + Application management
├── charts/                # Helm charts
```



## Cloning the Repository
1. Clone the repo
```shell
git clone <repository-url>
```

2. Checkout branch `final-project`
```shell
git checkout final-project
```

## AWS Configuration

```bash
aws configure
# Enter your AWS credentials
```
---

## Preparing the Backend (S3 + DynamoDB)

Before you start, you need to create the backend to store the Terraform state (terraform.tfstate) and to enable locking to prevent conflicts during team collaboration.
To do this:

1. Navigate to the `s3-backend` folder:

```bash
cd s3-backend
```

2. Initialize Terraform, review the plan, and create the backend resources:

```bash
terraform init
terraform plan
terraform apply
```

This will create:

- An S3 bucket to store the state
- A DynamoDB table for state locking

---

## Creating the Infrastructure

After the backend is created, return to the root folder with the main Terraform configuration and run the standard commands to create the infrastructure.

It is recommended to comment out the s3_backend creation block in main.tf and the output data of this module in outputs.tf before this.

Initialize Terraform:

```bash
terraform init
```

Review the changes:

```bash
terraform plan
```

Apply the changes:

```bash
terraform apply
```

View the outputs:

```bash
terraform output
```
---


## Deploying an Application with Kubernetes and Helm

Before you begin, please make sure the following tools are installed:
- Install [kubectl](https://kubernetes.io/docs/tasks/tools/)
- Install [helm](https://helm.sh/docs/intro/install/)

Get access to EKS cluster
```bash
aws eks update-kubeconfig --region <region> --name <cluster_name>
```

## Building and pushing a Docker image to ECR repository

Authenticate Docker with ECR
```bash
aws ecr get-login-password --region <your-region> | docker login --username AWS --password-stdin <your-account-id>.dkr.ecr.<your-region>.amazonaws.com
```

Build the Docker image
```bash
docker build -t <your-ecr-repo-name> ./docker
```
Tag the image
```bash
docker tag <your-ecr-repo-name>:latest <your-account-id>.dkr.ecr.<your-region>.amazonaws.com/<your-ecr-repo-name>:latest
```
Push the image to the ECR repository
```bash
docker push <your-account-id>.dkr.ecr.<your-region>.amazonaws.com/<your-ecr-repo-name>:latest
```

## Deploy Application using Helm

Navigate to the `helm charts` folder:
```bash
cd charts/django-app
```

Install the Helm release
```bash
helm install <your-app-name> .
```

Upgrade the Helm release
```bash
helm upgrade <your-app-name> .
```

## Accessing the Application

Find the LoadBalancer address (EXTERNAL-IP)
```bash
kubectl get svc
```

Open the EXTERNAL-IP in your browser
```bash
http://<external-dns>
```

![Django](assets/django.jpg)

## Checking the Deployment

List all Kubernetes resources
```bash
kubectl get all
```

Check the logs of the pods
```bash
kubectl logs -f <pod_name>
```
## Jenkins CI module

Find the Jenkins LoadBalancer address (EXTERNAL-IP)
```bash
kubectl get svc -n jenkins
```
Open the Jenkins EXTERNAL-IP in your browser
```bash
http://<external-dns>
```
To get the password, run the command and copy the result (login is `admin`)
```bash
kubectl get secret jenkins -n jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode && echo
```
![Jenkins](assets/jenkins.jpg)

After logging into Jenkins you will see the seed-job on the main Dashboard page. 
* Go to the seed-job pipeline and click on Build now 
* For the first run you need to approve the script, for this go to Dashboard -> Manage Jenkins -> In-process Script Approval and approve the seed-job 
* As a result of executing the seed-job the goit-django-docker pipeline should be created

In order for the goit-django-docker pipeline to be executed with each push to the django/ project directory, you need to configure the GitHub Webhook \
To do this, in your Github project, go to `Settings -> Webhooks -> Add Webhooks` \
As a Payload URL, specify the following address
```bash
http://<jenkins-external-dns>/github-webhook/
```
Content type specify `application/json`

In order for the pipeline not to be launched with a push that Argo CD makes, you need to go to
Manage Jenkins -> Plugins in the Jenkins interface and install the `SCM Skip` plugin

---

## Argo CD module

Find the ArgoCD LoadBalancer address (EXTERNAL-IP)
```bash
kubectl get svc -n argocd
```
Open the ArgoCD EXTERNAL-IP in your browser
```bash
http://<external-dns>
```

To get the password, run the command and copy the result (login is `admin`)
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath={.data.password} | base64 -d
```
![ArgoCD](assets/argocd.jpg)

After logging in, the app should be in Healthy status.

---

## RDS / Aurora Module

This module allows you to create both a regular RDS database (PostgreSQL / MySQL) and an Aurora cluster (Aurora PostgreSQL / Aurora MySQL), as well as:

After running terraform apply the endpoint is available in the outputs variable rds_endpoint. 

```bash
terraform output rds_endpoint
```

Example of connecting to the database:

```bash
psql --host=<your_rds_endpoint> \
     --port=5432 \
     --username=mydbuser \
     --dbname=mydatabase
```


## Variables Explained
| Variable               | Type           | Description                              |
|------------------------|----------------|------------------------------------------|
| `name`                 | `string`       | Name for the DB instance or Aurora сluster          |
| `use_aurora`           | `bool`         | Enables Aurora cluster if true           |
| `engine`               | `string`       | Engine type, e.g., `postgres` or `mysql` |
| `db_name`              | `string`       | Name of the default database             |
| `username`             | `string`       | Master DB username                       |
| `password`             | `string`       | Master DB password (sensitive)           |
| `allocated_storage`    | `number`       | Size in GB (for RDS only)                |
| `parameter_group_family_rds` | `string` | Family for RDS Parameter Group           |
| `aurora_instance_count`|`number`|Number of Aurora DB instances (1 = writer only)|
| `instance_class`       | `string`       | Instance size (e.g., db.t3.micro, db.t3.medium)          |
| `port`             | `number`       | Port used by the DB (5432 for PostgreSQL)                       |
| `vpc_id`              | `string`       | ID of the VPC where the DB should be provisioned             |
| `subnet_private_ids`      | `list(string)` | Private subnets to use for subnet group                                  |
| `subnet_public_ids`       | `list(string)` | Public subnets (used if `publicly_accessible = true`)                    |
| `publicly_accessible`     | `bool`        | Whether the DB is publicly available over the internet                   |
| `multi_az`                | `bool`        | If true, deploys standby instance in another AZ (for standard RDS)       |
| `backup_retention_period`| `number`      | Number of days to retain backups                                         |
| `parameters`             | `map(string)` | Parameter overrides for parameter group                                  |
| `tags`                   | `map(string)` | Optional tags for all resources                                          |


## How to Change Engine Type / Deployment Mode

### Standard PostgreSQL on RDS

```hcl
use_aurora                 = false
engine                    = "postgres"
engine_version            = "15.4"
parameter_group_family_rds = "postgres15"
```

### MySQL
```hcl
use_aurora                 = false
engine                    = "mysql"
engine_version            = "8.0"
parameter_group_family_rds = "mysql8.0"
```

### Aurora PostgreSQL
```hcl
use_aurora             = true
engine_cluster             = "aurora-postgresql"
engine_version_cluster     = "15.3"
parameter_group_family_aurora = "aurora-postgresql15"
```

![Aurora](assets/aurora.jpg)


---

## Monitoring module

Module automatically installs Prometheus and Grafana in the EKS cluster \
\
You can check the deployment:
```bash
kubectl get all -n monitoring
```
Find out the name of the Prometheus service (default is `kube-prometheus-stack-prometheus`)
```bash
terraform output prometheus_service_name 
```
Access the Prometheus interface on localhost via port forwarding
```bash
kubectl port-forward -n monitoring svc/<prometheus_service_name> 9090:80
```
Then open in browser
```bash
http://localhost:9090
```
![Prometheus](assets/prometheus.jpg)


Find out the name of the Grafana service (default is `kube-prometheus-stack-grafana`)
```bash
terraform output grafana_service_name
```
To get the password, run the command and copy the result (login is `admin`)
```bash
kubectl get secret --namespace monitoring kube-prometheus-stack-grafana -o jsonpath="{.data.admin-password}" | base64 --decode
```
Find the Grafana LoadBalancer address (EXTERNAL-IP)
```bash
kubectl get svc -n monitoring
```
Open the Grafana EXTERNAL-IP in your browser
```bash
http://<external-dns>
```

![Grafana](assets/grafana.jpg)

---

## Removing Resources

Check the Helm release name (e.g., django-app):

```bash
helm list
```

Uninstall the Helm release

```bash
helm uninstall <your-app-name>
```

## Destroying the Infrastructure

If you need to remove the infrastructure created with Terraform

```bash
terraform destroy
```
To completely clean up cached files, you can run:

```bash
rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup
```