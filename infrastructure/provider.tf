terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.48.0"
    }
  }
  backend "s3" {
    bucket         = "poc-webapi-terraform-state-bucket"
    key            = "my-app/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
  }
}