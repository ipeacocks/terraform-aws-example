variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "credentials" {
  default     = ["~/.aws/credentials"]
  description = "Where your access and secret_key are stored, you create the file when you run the aws config"
}

variable "helm_package_version" {
  type        = string
  description = "Helm package version for fluent operator."
  default     = "4.3.0"
}

variable "namespace" {
  description = "Namespace to which service will be deployed."
  type        = string
  default     = "fluent"
}

variable "es_host" {
  type        = string
  description = "Elasticsearch host to send logs to (IP address or hostname)."
  default     = "elasticsearch.elastic.svc"
}

variable "resources" {
  description = "FluentBit daemonset resources."
  type = object({
    limits = optional(object({
      cpu    = optional(string, "1000m")
      memory = optional(string, "1000Mi")
    }), {})
    requests = optional(object({
      cpu    = optional(string, "100m")
      memory = optional(string, "250Mi")
    }), {})
  })
  default = {}
}
