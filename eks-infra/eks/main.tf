data "aws_availability_zones" "available" {}

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "my-tf-state-2023-06-01"
    key    = "my-vpc.tfstate"
    region = "us-east-1"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.2"

  cluster_name    = data.terraform_remote_state.vpc.outputs.eks_cluster_name
  cluster_version = var.cluster_version

  vpc_id                         = data.terraform_remote_state.vpc.outputs.vpc_id
  control_plane_subnet_ids       = data.terraform_remote_state.vpc.outputs.control_plane_subnet_ids
  subnet_ids                     = data.terraform_remote_state.vpc.outputs.worker_subnet_ids
  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = var.eks_managed_node_group_defaults
  eks_managed_node_groups         = var.eks_managed_node_groups
}
