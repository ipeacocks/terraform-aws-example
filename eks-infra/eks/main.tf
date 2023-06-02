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
  cluster_version = "1.27"

  vpc_id                         = data.terraform_remote_state.vpc.outputs.vpc_id
  control_plane_subnet_ids       = data.terraform_remote_state.vpc.outputs.control_plane_subnet_ids
  subnet_ids                     = data.terraform_remote_state.vpc.outputs.worker_subnet_ids
  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }

  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      instance_types = ["t3.small"]

      min_size     = 2
      max_size     = 3
      desired_size = 2
    }
  }
}
