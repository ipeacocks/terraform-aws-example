terraform {
  required_version = ">= 1.13.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.12.0"
    }
  }

  backend "s3" {
    bucket = "my-tf-state-2023-06-01"
    key    = "my-eks.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region                   = var.region
  shared_credentials_files = var.credentials
}
