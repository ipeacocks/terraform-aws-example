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
  description = "Version of the helm package."
  type        = string
  default     = "8.3.8"
}

variable "route53_zone_ids" {
  description = "Route53 zone IDs to be served by external-dns addon."
  type        = list(string)
  default     = ["Z04055631FR4AIE80F1GK", "Z056915018W8C59H17J0X"]
}
