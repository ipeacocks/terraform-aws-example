data "terraform_remote_state" "eks" {
  backend = "s3"

  config = {
    bucket = "my-tf-state-2023-06-01"
    key    = "my-eks.tfstate"
    region = "us-east-1"
  }
}

resource "aws_iam_policy" "this" {
  name        = "eks-ascp-${data.terraform_remote_state.eks.outputs.cluster_name}-${var.region}"
  path        = "/"
  description = "AWS ASCP controller IAM policy."
  policy      = file(format("%s/templates/policy.json", path.module))
}

resource "aws_iam_role" "this" {
  name = "eks-ascp-${data.terraform_remote_state.eks.outputs.cluster_name}-${var.region}"
  assume_role_policy = templatefile("${path.module}/templates/assume_policy.json_tpl",
    {
      oidc_provider     = data.terraform_remote_state.eks.outputs.oidc_provider,
      oidc_provider_arn = data.terraform_remote_state.eks.outputs.oidc_provider_arn
  })
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

resource "helm_release" "csi_secrets_store" {
  name       = "csi-secrets-store"
  repository = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
  chart      = "secrets-store-csi-driver"
  version    = var.csi_secrets_store_helm_version
  namespace  = "kube-system"
}

# AWS Secrets and Configuration Provider (ASCP)
resource "helm_release" "aws_secrets_manager" {
  name       = "secrets-store-csi-driver-provider-aws"
  repository = "https://aws.github.io/secrets-store-csi-driver-provider-aws"
  chart      = "secrets-store-csi-driver-provider-aws"
  version    = var.aws_secrets_manager_helm_version
  namespace  = "kube-system"
}
