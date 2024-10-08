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
  type        = string
  description = "Version of the helm package."
  default     = "0.10.3"
}

variable "external_secrets_ssm_parameter_arns" {
  type        = list(any)
  description = "Parameter Store arns list."
  default     = ["arn:aws:ssm:us-east-1:789248082627:parameter/dev/*"]
}


variable "external_secrets_secrets_manager_arns" {
  type        = list(any)
  description = "Secrets manager arns list."
  default     = ["arn:aws:secretsmanager:us-east-1:789248082627:secret:dev/*"]
}


variable "external_secrets_kms_key_arns" {
  type        = list(any)
  description = "KMS keys arns for decoding."
  default     = ["arn:aws:kms:us-east-1:789248082627:key/9a04d3c9-1589-42b3-9dca-296b6a51c695"]
}
