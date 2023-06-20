# Details https://github.com/terraform-aws-modules/terraform-aws-eks#inputs

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "credentials" {
  default     = ["~/.aws/credentials"]
  description = "where your access and secret_key are stored, you create the file when you run the aws config"
}

variable "eks_name_prefix" {
  description = "EKS cluster name prefix"
  type        = string
  default     = "my-eks"
}

variable "cluster_version" {
  description = "EKS version"
  type        = number
  default     = "1.27"
}

variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled"
  type        = bool
  default     = true
}

variable "eks_managed_node_group_defaults" {
  description = "Map of EKS managed node group default configurations"
  default     = { ami_type = "AL2_x86_64" }
}

variable "eks_managed_node_groups" {
  description = "Map of EKS managed node group definitions to create"
  default = {
    one = {
      name = "node-group-1"

      instance_types = ["t3.small"]

      min_size     = 2
      max_size     = 3
      desired_size = 2
    }
  }
}
