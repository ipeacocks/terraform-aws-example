data "terraform_remote_state" "eks" {
  backend = "s3"

  config = {
    bucket = "my-tf-state-2023-06-01"
    key    = "my-eks.tfstate"
    region = "us-east-1"
  }
}

module "aws_lb_controller_pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "2.0.0"

  name = "aws-lbc"

  attach_aws_lb_controller_policy = true

  # Pod Identity Associations
  association_defaults = {
    namespace       = "kube-system"
    service_account = "aws-load-balancer-controller"
  }

  associations = {
    one = {
      cluster_name = data.terraform_remote_state.eks.outputs.cluster_name
    }
  }
}

resource "helm_release" "this" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = var.helm_package_version
  namespace  = "kube-system"

  set = [
    {
      name  = "clusterName"
      value = data.terraform_remote_state.eks.outputs.cluster_name
    },
    {
      name  = "serviceAccount.create"
      value = "true"
    },
    {
      name  = "serviceAccount.name"
      value = "aws-load-balancer-controller"
    }
  ]
}
