variable "bucket_name" {
  description = "The name of the S3 bucket for Terraform state"
  type        = string
  default     = "terraform-state-bucket-alx"
}

variable "table_name" {
  description = "The name of the DynamoDB table for Terraform locks"
  type        = string
  default     = "terraform-locks"
}