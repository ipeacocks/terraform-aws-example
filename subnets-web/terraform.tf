# S3 bucket and DynamoDB table need to be created before

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "s3" {
    bucket         = "my-tf-state-15"
    dynamodb_table = "my-inf-tflock"
    key            = "my-inf.tfstate"
    region         = "us-east-1"
  }
}

provider "aws" {
  region                   = var.region
  shared_credentials_files = var.credentials
  # access_key               = "my-access-key"
  # secret_key               = "my-secret-key"
}