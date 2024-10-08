variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "credentials" {
  default     = ["~/.aws/credentials"]
  description = "where your access and secret_key are stored, you create the file when you run the aws config."
}

variable "csi_secrets_store_helm_version" {
  default     = "1.4.5"
  description = "Helm package version of CSI Secret Store"
}

variable "aws_secrets_manager_helm_version" {
  default     = "0.3.9"
  description = "Helm package version of AWS Secret Manager"
}
