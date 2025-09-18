output "s3_bucket_name" {
  description = "Name of the S3 bucket for states"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "s3_bucket_url" {
  description = "URL of the S3 bucket for states"
  value       = "https://${aws_s3_bucket.terraform_state.bucket_regional_domain_name}"
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table for state locking"
  value       = aws_dynamodb_table.terraform_locks.name
}


