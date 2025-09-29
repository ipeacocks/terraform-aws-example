# Details https://github.com/terraform-aws-modules/terraform-aws-eks#inputs

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "credentials" {
  default     = ["~/.aws/credentials"]
  description = "Where your access and secret_key are stored, you create the file when you run the aws config"
}

variable "eks_name" {
  description = "EKS cluster name"
  type        = string
  default     = "my-eks"
}

variable "eks_version" {
  description = "EKS version"
  type        = string
  default     = "1.33"
}

# can be false if you connect to private network via VPN or something
variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled"
  type        = bool
  default     = true
}

variable "eks_managed_node_groups" {
  description = "Map of EKS managed node group definitions to create"
  default = {
    one = {
      name = "node-group-1"
      
      # Because Argo Rollouts test images don't support ARM64
      ami_type       = "AL2023_x86_64_STANDARD" # AL2023_ARM_64_STANDARD
      instance_types = ["t3a.medium"]           # t4g.medium

      min_size     = 2
      max_size     = 3
      desired_size = 2

      metadata_options = {
        http_endpoint               = "enabled"
        http_put_response_hop_limit = 2
        http_tokens                 = "required"
      }
    }
  }
}

variable "node_security_group_additional_rules" {
  description = "Node to node traffic access"
  default = {
    ingress_self_any = {
      description = "Node to node All"
      protocol    = "all"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_self_any = {
      description = "Node to node All"
      protocol    = "all"
      from_port   = 0
      to_port     = 0
      type        = "egress"
      self        = true
    }
  }
}

# maybe better to pin versions here
variable "eks_addons" {
  description = "Map of cluster addon configurations to enable for the cluster"
  default = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent    = true
      before_compute = true
    }
    eks-pod-identity-agent = {
      most_recent = true
    }
  }
}

# here should be your account ID
variable "kms_key_administrators" {
  description = "A list of IAM ARNs for key administrators"
  default     = ["arn:aws:iam::789248082627:root"]
}

variable "enable_cluster_creator_admin_permissions" {
  description = "Indicates whether or not to add the cluster creator (the identity used by Terraform) as an administrator via access entry"
  default     = true
}
