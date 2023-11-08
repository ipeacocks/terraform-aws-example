terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.24.0"
    }
  }

  backend "s3" {
    bucket = "my-tf-state-2023-06-01"
    key    = "my-eks.tfstate"
    region = "us-east-1"
  }

  required_version = "~> 1.6"
}

provider "aws" {
  region                   = var.region
  shared_credentials_files = var.credentials
}

# provider "kubernetes" {
#   host                   = aws_eks_cluster.this[0].endpoint
#   cluster_ca_certificate = base64decode(aws_eks_cluster.this[0].certificate_authority[0].data)

#   exec {
#     api_version = "client.authentication.k8s.io/v1beta1"
#     command     = "aws"
#     args        = ["eks", "get-token", "--role", "${dependency.data.outputs.iam_assumed_role_arn}", "--cluster-name", aws_eks_cluster.this[0].name]
#   }
# }
