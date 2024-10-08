variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "credentials" {
  default     = ["~/.aws/credentials"]
  description = "where your access and secret_key are stored, you create the file when you run the aws config"
}

variable "addon_version" {
  type        = string
  description = "Version of EKS addon."
  default     = "v1.34.0-eksbuild.1"
}

variable "volume_tags" {
  type        = map(any)
  description = "Volume tags."
  # Can't be changed w/o recreating of StorageClass K8s object
  default = {
    env_name = "development"
    region   = "us-east-1"
    team     = "devops"
  }
}
