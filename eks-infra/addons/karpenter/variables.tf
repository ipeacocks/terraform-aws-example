variable "region" {
  description = "AWS region."
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
  default     = "1.4.0"
}

variable "namespace" {
  description = "Namespace to which service will be deployed."
  type        = string
  default     = "kube-system"
}

variable "name_prefix" {
  description = "Name part to be attached to module resources."
  type        = string
  default     = "eks-karpenter"
}

variable "tags" {
  description = "Resources tags."
  type        = map(string)
  default = {
    cluster-name = "my-eks"
    node-group   = "dynamic"
    team         = "devops"
  }
}

variable "generic_node_pool" {
  description = "Configuration object for generic node pool."
  type = object({
    disruption = optional(object({
      consolidation_policy = optional(string, "WhenEmptyOrUnderutilized")
      consolidate_after    = optional(string, "1m")
    }), {})
    expire_after = optional(string, "720h")
    instance = optional(object({
      min_cpu       = optional(number, 4)
      min_memory_mb = optional(number, 8192)
    }), {})
  })
  default = {}
}
