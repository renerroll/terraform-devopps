# Create an S3 bucket
resource "aws_s3_bucket" "terraform_state" {
  bucket = var.bucket_name                         # The bucket name, which must be unique across AWS globally
  tags = {
    Name        = "Terraform State Bucket"
    Environment = "lesson-5"
  }
}

# Enable versioning for the S3 bucket
resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id       # Links this resource to the previously created bucket
  versioning_configuration {
    status = "Enabled"                            # Enabling versioning allows keeping the history of file changes in the bucket
  }
}

# Set ownership controls for the S3 bucket
resource "aws_s3_bucket_ownership_controls" "terraform_state_ownership" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    object_ownership = "BucketOwnerEnforced"      # Ensures the bucket owner has full control over all objects
  }
}

