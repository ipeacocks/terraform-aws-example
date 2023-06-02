terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0.0"
    }
  }

  backend "s3" {
    bucket = "my-tf-state-2023-06-01"
    key    = "my-vpc.tfstate"
    region = "us-east-1"
  }

  required_version = "~> 1.4"

}

provider "aws" {
  region                   = var.region
  shared_credentials_files = var.credentials
}