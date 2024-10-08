data "terraform_remote_state" "eks" {
  backend = "s3"

  config = {
    bucket = "my-tf-state-2023-06-01"
    key    = "my-eks.tfstate"
    region = "us-east-1"
  }
}

resource "helm_release" "this" {
  name       = "metrics-servers"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = var.helm_package_version
  namespace  = var.namespace

  set {
    name  = "replicas"
    value = 2
  }
}
