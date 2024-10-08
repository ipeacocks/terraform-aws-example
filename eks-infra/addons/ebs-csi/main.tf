data "terraform_remote_state" "eks" {
  backend = "s3"

  config = {
    bucket = "my-tf-state-2023-06-01"
    key    = "my-eks.tfstate"
    region = "us-east-1"
  }
}

module "aws_ebs_csi_pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "v1.4.1"

  name = "aws-ebs-csi"

  attach_aws_ebs_csi_policy = true
  # aws_ebs_csi_kms_arns      = ["arn:aws:kms:*:*:key/1234abcd-12ab-34cd-56ef-1234567890ab"]

  association_defaults = {
    namespace       = "kube-system"
    service_account = "ebs-csi-controller-sa"
  }

  associations = {
    one = {
      cluster_name = data.terraform_remote_state.eks.outputs.cluster_name
    }
  }
}

resource "aws_eks_addon" "this" {
  cluster_name             = data.terraform_remote_state.eks.outputs.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = var.addon_version
  # service_account_role_arn = module.irsa_role.iam_role_arn
}

data "kubectl_path_documents" "storage_class" {
  pattern = "templates/sc.tpl.yaml"
  vars = {
    # Produces string like "env_name=development,region=us-east-1,team=devops"
    tag_specifications = join(",", [for key, value in var.volume_tags : "${key}=${value}"])
  }
}

resource "kubectl_manifest" "storage_class" {
  count     = length(data.kubectl_path_documents.storage_class.documents)
  yaml_body = element(data.kubectl_path_documents.storage_class.documents, count.index)
}
