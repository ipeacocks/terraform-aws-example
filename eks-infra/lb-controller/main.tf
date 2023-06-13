data "aws_availability_zones" "available" {}

data "aws_caller_identity" "current" {}

data "terraform_remote_state" "eks" {
  backend = "s3"

  config = {
    bucket = "my-tf-state-2023-06-01"
    key    = "my-eks.tfstate"
    region = "us-east-1"
  }
}

resource "aws_iam_policy" "AWSLoadBalancerControllerIAMPolicy" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  path        = "/"
  description = "AWS LB controller IAM policy"
  policy      = file(format("%s/policies/AWSLoadBalancerControllerIAMPolicy.json", path.module))
}

data "template_file" "value_generated" {
  template = file(format("%s/policies/AmazonEKSLoadBalancerControllerPolicy.json_tmpl", path.module))

  vars = {
    oidc_provider     = data.terraform_remote_state.eks.outputs.oidc_provider
    oidc_provider_arn = data.terraform_remote_state.eks.outputs.oidc_provider_arn
  }
}

resource "aws_iam_role" "role" {
  name               = "AmazonEKSLoadBalancerControllerRole"
  assume_role_policy = data.template_file.value_generated.rendered
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.AWSLoadBalancerControllerIAMPolicy.arn
}

# Correct way to login but not working for me
# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs#exec-plugins
# data "aws_eks_cluster" "eks" {
#   name = data.terraform_remote_state.eks.outputs.cluster_name
# }

# provider "kubernetes" {
#   host                   = data.aws_eks_cluster.eks.endpoint
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
#   exec {
#     api_version = "client.authentication.k8s.io/v1beta1"
#     args        = ["eks", "get-token", "--cluster-name", data.terraform_remote_state.eks.outputs.cluster_name]
#     command     = "aws"
#   }
# }

# aws cli needs to be configured with login/pass
resource "null_resource" "update-local-kube-config" {
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --region ${var.region} --name ${data.terraform_remote_state.eks.outputs.cluster_name}"
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubectl_manifest" "ServiceAccount" {
  yaml_body = <<YAML
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/name: aws-load-balancer-controller
  name: aws-load-balancer-controller
  namespace: kube-system
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/AmazonEKSLoadBalancerControllerRole
YAML
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "aws-load-balancer-controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = var.aws-load-balancer-controller_version
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = data.terraform_remote_state.eks.outputs.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
}