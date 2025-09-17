terraform {
  backend "s3" {
    bucket         = "my-terraform-bucket-lesson5"
    key            = "lesson-5/terraform.tfstate"
    region = "eu-north-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

