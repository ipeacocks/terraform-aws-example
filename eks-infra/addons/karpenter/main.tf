data "terraform_remote_state" "eks" {
  backend = "s3"

  config = {
    bucket = "my-tf-state-2023-06-01"
    key    = "my-eks.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "my-tf-state-2023-06-01"
    key    = "my-vpc.tfstate"
    region = "us-east-1"
  }
}

data "aws_caller_identity" "current" {}

locals {
  name = "${var.name_prefix}-${data.terraform_remote_state.eks.outputs.cluster_name}-${var.region}"
}

module "this" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "20.35.0"

  cluster_name               = data.terraform_remote_state.eks.outputs.cluster_name
  iam_policy_name            = local.name
  iam_policy_use_name_prefix = false
  enable_v1_permissions      = true
  iam_role_name              = local.name
  iam_role_use_name_prefix   = false
  queue_name                 = local.name
  create_node_iam_role       = false
  node_iam_role_arn          = format("arn:aws:iam::%s:role/%s", data.aws_caller_identity.current.account_id, data.terraform_remote_state.eks.outputs.eks_managed_node_groups["one"].iam_role_name)
  # Since the nodegroup role will already have an access entry
  create_access_entry = false
}

resource "aws_eks_pod_identity_association" "this" {
  cluster_name    = data.terraform_remote_state.eks.outputs.cluster_name
  namespace       = var.namespace
  service_account = "karpenter"
  role_arn        = module.this.iam_role_arn
}

resource "helm_release" "crd" {
  name             = "karpenter-crd"
  repository       = "oci://public.ecr.aws/karpenter"
  chart            = "karpenter-crd"
  version          = var.helm_package_version
  namespace        = var.namespace
  create_namespace = true
}

resource "helm_release" "this" {
  name             = "karpenter"
  repository       = "oci://public.ecr.aws/karpenter"
  chart            = "karpenter"
  version          = var.helm_package_version
  namespace        = var.namespace
  create_namespace = true
  values = [
    templatefile("${path.module}/templates/helm/values.yaml.tpl", {
      clusterName           = data.terraform_remote_state.eks.outputs.cluster_name
      interruptionQueueName = module.this.queue_name
    })
  ]

  depends_on = [helm_release.crd]
}

resource "kubectl_manifest" "generic_ec2_node_class" {
  yaml_body = templatefile("${path.module}/templates/manifests/generic-ec2nodeclass.yaml.tpl", {
    private_subnets                = join(",", data.terraform_remote_state.vpc.outputs.worker_subnet_ids)
    cluster_node_security_group_id = data.terraform_remote_state.eks.outputs.node_security_group_id
    cluster_name                   = data.terraform_remote_state.eks.outputs.cluster_name
    role                           = data.terraform_remote_state.eks.outputs.eks_managed_node_groups["one"].iam_role_name
    tags                           = join(",", [for key, value in var.tags : "${key}: '${value}'"])
  })

  depends_on = [helm_release.this]
}

resource "kubectl_manifest" "generic_node_pool" {
  yaml_body = templatefile("${path.module}/templates/manifests/generic-nodepool.yaml.tpl", {
    disruption = {
      consolidation_policy = var.generic_node_pool.disruption.consolidation_policy
      consolidate_after    = var.generic_node_pool.disruption.consolidate_after
    }
    expire_after = var.generic_node_pool.expire_after
    instance = {
      # Because Karpeter has only greater operator.
      min_cpu    = var.generic_node_pool.instance.min_cpu - 1
      min_memory = var.generic_node_pool.instance.min_memory_mb - 1
    }
  })

  depends_on = [helm_release.this]
}
