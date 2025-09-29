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
  version = "21.1.5"

  name               = var.eks_name
  kubernetes_version = var.eks_version
  addons             = var.eks_addons

  vpc_id                         = data.terraform_remote_state.vpc.outputs.vpc_id
  control_plane_subnet_ids       = data.terraform_remote_state.vpc.outputs.control_plane_subnet_ids
  subnet_ids                     = data.terraform_remote_state.vpc.outputs.worker_subnet_ids
  endpoint_public_access         = var.cluster_endpoint_public_access

  eks_managed_node_groups              = var.eks_managed_node_groups
  node_security_group_additional_rules = var.node_security_group_additional_rules

  kms_key_administrators                   = var.kms_key_administrators
  enable_cluster_creator_admin_permissions = var.enable_cluster_creator_admin_permissions
}
