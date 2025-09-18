# Create a DynamoDB table for Terraform state locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"      # On-demand billing mode. You pay only for the operations you perform on the table.
  hash_key     = "LockID"               # Primary key for the table, used to store the lock.

  attribute {
    name = "LockID"
    type = "S"                          # Specifies that the LockID key is a string (S — String).
  }

  tags = {
    Name        = "Terraform Lock Table"
    Environment = "lesson-5"
  }
}

