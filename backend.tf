terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-alx"     # Name of the S3 bucket
    key            = "terraform.tfstate"              # Path to the state file (path inside the bucket)
    region         = "eu-west-1"                      # AWS region
    dynamodb_table = "terraform-locks"                # Name of the DynamoDB table — table for state locking
    encrypt        = true                             # Encryption of the state file
  }
}
