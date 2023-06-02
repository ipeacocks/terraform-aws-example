locals {
  control_plane_subnets_length = length(local.control_plane_subnets)
  # worker_subnets_length = length(local.worker_subnets)
  private_subnets_length = length(module.vpc.private_subnets)
}

output "region" {
  description = "AWS region"
  value       = var.region
}

output "vpc_id" {
  description = "VPC id"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "Public subnets"
  value       = module.vpc.public_subnets
}

# output "private_subnets" {
#   description = "Private subnets"
#   value       = module.vpc.private_subnets
# }

output "control_plane_subnet_ids" {
  description = "Private subnets for Control plane"
  value       = slice(module.vpc.private_subnets, 0, local.control_plane_subnets_length)
}

output "worker_subnet_ids" {
  description = "Private subnets for Worker nodes"
  value       = slice(module.vpc.private_subnets, local.control_plane_subnets_length, local.private_subnets_length)
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = local.cluster_name
}