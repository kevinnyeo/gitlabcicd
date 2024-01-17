terraform {
  backend "s3" {
    bucket = "kevinyyh-testbucket" # Replace with your actual S3 bucket name
    key    = "Gitlab/terraform.tfstate"
    region = "us-east-1"
  }
}
