variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "credentials" {
  default     = ["~/.aws/credentials"]
  description = "where your access and secret_key are stored, you create the file when you run the aws config"
}

variable "helm_package_version" {
  description = "Helm package version."
  type        = string
  default     = "3.12.1"
}

variable "namespace" {
  description = "Namespace service will be deployed to."
  type        = string
  default     = "kube-system"
}
