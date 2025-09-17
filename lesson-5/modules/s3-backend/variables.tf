variable "bucket_name" {
  description = "Назва S3 бакету для Terraform state"
  type        = string
}

variable "table_name" {
  description = "Назва таблиці DynamoDB для блокування"
  type        = string
}
