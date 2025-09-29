variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "helm_package_version" {
  description = "Helm package version."
  type        = string
  default     = "2.40.3"
}

variable "credentials" {
  default     = ["~/.aws/credentials"]
  description = "Where your access and secret_key are stored, you create the file when you run the aws config"
}

variable "namespace" {
  description = "Namespace service will be deployed to."
  type        = string
  default     = "argo-rollouts"
}

# variable "controller_iam_role_name" {
#   type        = string
#   description = "IAM role for Argo Rollouts."
#   default     = "eks-argo-rollouts-${dependency.cluster.outputs.cluster_name}-${var.region}"
# }

# variable "cluster_name" {
#   type        = string
#   description = "The name of the EKS cluster."
# }
