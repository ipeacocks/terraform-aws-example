terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.24.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11.0"
    }
    # kubectl = {
    #   source  = "alekc/kubectl"
    #   version = ">= 2.0.3"
    # }
  }

  backend "s3" {
    bucket = "my-tf-state-2023-06-01"
    key    = "my-lb-controller.tfstate"
    region = "us-east-1"
  }

  required_version = "~> 1.6"
}

provider "aws" {
  region                   = var.region
  shared_credentials_files = var.credentials
}

provider "helm" {
  kubernetes {
    host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
    cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", data.terraform_remote_state.eks.outputs.cluster_name]
    }
  }
}
