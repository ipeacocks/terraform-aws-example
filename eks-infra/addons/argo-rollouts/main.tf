data "aws_region" "this" {}

data "terraform_remote_state" "eks" {
  backend = "s3"

  config = {
    bucket = "my-tf-state-2023-06-01"
    key    = "my-eks.tfstate"
    region = "us-east-1"
  }
}

data "aws_iam_policy_document" "this" {

  statement {
    sid    = "LBAccess"
    effect = "Allow"
    actions = [
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeRules",
      "elasticloadbalancing:DescribeTags",
      "elasticloadbalancing:DescribeTargetHealth"
    ]
    resources = ["*"]
  }
}

resource "helm_release" "this" {
  name             = "argo-rollouts"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-rollouts"
  version          = var.helm_package_version
  namespace        = var.namespace
  create_namespace = true

  values = [
    templatefile("${path.module}/templates/helm/values.yaml.tpl", {
      region = data.aws_region.this.region
    })
  ]
}

module "custom_pod_identity" {

  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "2.0.0"

  name            = "eks-argo-rollouts-${data.terraform_remote_state.eks.outputs.cluster_name}-${var.region}"
  use_name_prefix = false

  attach_custom_policy = true
  source_policy_documents = [
    data.aws_iam_policy_document.this.json
  ]

  associations = {
    one = {
      cluster_name    = data.terraform_remote_state.eks.outputs.cluster_name
      namespace       = var.namespace
      service_account = "argo-rollouts"
    }
  }
}
