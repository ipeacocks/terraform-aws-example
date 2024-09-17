data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "my-tf-state-2023-06-01"
    key    = "my-vpc.tfstate"
    region = "us-east-1"
  }
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.24.0"

  cluster_name    = "${var.eks_name_prefix}-${random_string.suffix.result}"
  cluster_version = var.cluster_version
  cluster_addons  = var.cluster_addons

  vpc_id                         = data.terraform_remote_state.vpc.outputs.vpc_id
  control_plane_subnet_ids       = data.terraform_remote_state.vpc.outputs.control_plane_subnet_ids
  subnet_ids                     = data.terraform_remote_state.vpc.outputs.worker_subnet_ids
  cluster_endpoint_public_access = var.cluster_endpoint_public_access

  eks_managed_node_group_defaults      = var.eks_managed_node_group_defaults
  eks_managed_node_groups              = var.eks_managed_node_groups
  node_security_group_additional_rules = var.node_security_group_additional_rules

  kms_key_administrators                   = var.kms_key_administrators
  enable_cluster_creator_admin_permissions = var.enable_cluster_creator_admin_permissions
}
