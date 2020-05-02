/*
terraform {
  required_version = "~> v0.12"

  backend "s3" {
    encrypt = true

    bucket = "terraform-state-bea832"
    key    = "ourdatastore/terraform.tfstate"
    region = "us-east-1"

    dynamodb_table = "terraform-locks-56a140"
  }
}
*/
