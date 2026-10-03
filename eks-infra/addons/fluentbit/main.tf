data "kubectl_path_documents" "this" {
  pattern = "${path.module}/templates/manifests/*.yaml.tpl"
  vars = {
    es_host = var.es_host
  }
}

data "terraform_remote_state" "eks" {
  backend = "s3"

  config = {
    bucket = "my-tf-state-2023-06-01"
    key    = "my-eks.tfstate"
    region = "us-east-1"
  }
}

resource "helm_release" "this" {
  name             = "fluent-operator"
  repository       = "https://fluent.github.io/helm-charts"
  chart            = "fluent-operator"
  version          = var.helm_package_version
  create_namespace = true
  namespace        = var.namespace
  values = [
    templatefile("${path.module}/templates/helm/values.yaml.tpl", {
      limits = {
        cpu    = var.resources.limits.cpu
        memory = var.resources.limits.memory
      }
      requests = {
        cpu    = var.resources.requests.cpu
        memory = var.resources.requests.memory
      }
    })
  ]
}

resource "kubectl_manifest" "this" {
  count = length(data.kubectl_path_documents.this.documents)

  yaml_body  = element(data.kubectl_path_documents.this.documents, count.index)
  depends_on = [helm_release.this]
}

module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.16.1"

  bucket = "fluentbit-logs-2026"

  versioning = {
    enabled = false
  }

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "this" {

  statement {
    sid    = "S3Write"
    effect = "Allow"

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject"
    ]

    resources = [
      "${module.s3_bucket.s3_bucket_arn}/*"
    ]
  }
}

module "custom_pod_identity" {

  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "2.9.0"

  name            = "eks-fluentbit-${data.terraform_remote_state.eks.outputs.cluster_name}-${var.region}"
  use_name_prefix = false

  attach_custom_policy = true
  source_policy_documents = [
    data.aws_iam_policy_document.this.json
  ]

  associations = {
    one = {
      cluster_name    = data.terraform_remote_state.eks.outputs.cluster_name
      namespace       = var.namespace
      service_account = "fluent-bit"
    }
  }
}
