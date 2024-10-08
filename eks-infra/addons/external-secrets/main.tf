data "terraform_remote_state" "eks" {
  backend = "s3"

  config = {
    bucket = "my-tf-state-2023-06-01"
    key    = "my-eks.tfstate"
    region = "us-east-1"
  }
}

module "external_secrets_pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "v1.4.1"

  name = "external-secrets"

  attach_external_secrets_policy        = true
  external_secrets_ssm_parameter_arns   = var.external_secrets_ssm_parameter_arns
  external_secrets_secrets_manager_arns = var.external_secrets_secrets_manager_arns
  external_secrets_kms_key_arns         = var.external_secrets_kms_key_arns
  external_secrets_create_permission    = true

  association_defaults = {
    namespace       = "kube-system"
    service_account = "external-secrets"
  }

  associations = {
    one = {
      cluster_name = data.terraform_remote_state.eks.outputs.cluster_name
    }
  }
}

resource "helm_release" "external_secrets" {
  name       = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  version    = var.helm_package_version
  namespace  = "kube-system"

  set {
    name  = "serviceAccount.create"
    value = "true"
  }
}
