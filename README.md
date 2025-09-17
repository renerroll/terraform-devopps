# RDS Terraform Module

This module allows you to create both a regular RDS database (PostgreSQL / MySQL) and an Aurora cluster (Aurora PostgreSQL / Aurora MySQL), as well as:

- DB Subnet Group (private or public subnets)
- Security Group with an open port
- Parameter Group with arbitrary parameters
- Support for Multi-AZ, replicas and production-ready configuration

---

## 📦 Example of use

```hcl
module "rds" {
  source = "./modules/rds"

  name                       = "myapp-db"
  use_aurora                 = false
  aurora_instance_count      = 2

  # RDS only
  engine                     = "postgres"
  engine_version             = "15.4"
  parameter_group_family_rds = "postgres15"

  # Common
  instance_class             = "db.t3.micro"
  allocated_storage          = 20
  db_name                    = "myapp"
  username                   = "django_user"
  password                   = "secure_password"
  port                       = 5432

  vpc_id                     = module.vpc.vpc_id
  subnet_private_ids         = module.vpc.private_subnets
  subnet_public_ids          = module.vpc.public_subnets
  publicly_accessible        = false
  multi_az                   = false
  backup_retention_period    = 7

  parameters = {
    max_connections             = "200"
    log_min_duration_statement = "500"
  }

  tags = {
    Environment = "dev"
    Project     = "myapp"
  }
}
```

## ⚙️ Variables Explained
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

### ☁️ Standard PostgreSQL on RDS

```hcl
use_aurora                 = false
engine                    = "postgres"
engine_version            = "15.4"
parameter_group_family_rds = "postgres15"
```

### ☁️ MySQL
```hcl
use_aurora                 = false
engine                    = "mysql"
engine_version            = "8.0"
parameter_group_family_rds = "mysql8.0"
```

### ☁️ Aurora PostgreSQL
```hcl
use_aurora             = true
engine                 = "aurora-postgresql"
engine_version         = "15.3"
aurora_instance_count  = 2
```