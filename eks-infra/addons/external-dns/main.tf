data "terraform_remote_state" "eks" {
  backend = "s3"

  config = {
    bucket = "my-tf-state-2023-06-01"
    key    = "my-eks.tfstate"
    region = "us-east-1"
  }
}

data "aws_route53_zone" "this" {
  for_each = toset(var.route53_zone_ids)

  zone_id = each.key
}

locals {
  route53_zone_arns = [for k, v in data.aws_route53_zone.this : v.arn]
}

module "external_dns_pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "v1.4.1"

  name = "external-dns"

  attach_external_dns_policy = true
  # Array like ["arn:aws:route53:::hostedzone/Z04055631FR4AIE80F1GK",
  #             "arn:aws:route53:::hostedzone/Z056915018W8C59H17J0X"]
  external_dns_hosted_zone_arns = local.route53_zone_arns

  # Pod Identity Associations
  association_defaults = {
    namespace       = "kube-system"
    service_account = "external-dns"
  }

  associations = {
    one = {
      cluster_name = data.terraform_remote_state.eks.outputs.cluster_name
    }
  }
}

resource "helm_release" "this" {
  name       = "external-dns"
  repository = "oci://registry-1.docker.io/bitnamicharts"
  chart      = "external-dns"
  version    = var.helm_package_version
  namespace  = "kube-system"

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "provider"
    value = "aws"
  }

  set {
    name  = "txtOwnerId"
    value = "External-dns addon of ${data.terraform_remote_state.eks.outputs.cluster_name} EKS cluster"
  }

  set {
    name = "zoneIdFilters"
    # list like "{Z04055631FR4AIE80F1GK,Z056915018W8C59H17J0X}"
    value = format("{%s}", join(",", var.route53_zone_ids))
  }

  # it removes unused domains after removing related resources
  set {
    name  = "policy"
    value = "sync"
  }
}
