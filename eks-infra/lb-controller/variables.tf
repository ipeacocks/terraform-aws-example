variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "credentials" {
  default     = ["~/.aws/credentials"]
  description = "where your access and secret_key are stored, you create the file when you run the aws config"
}

variable "aws-load-balancer-controller_version" {
  default     = "1.5.3"
  description = "Helm package version of AWS LB Controller"
}