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
