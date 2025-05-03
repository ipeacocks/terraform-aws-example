# Details are here https://github.com/terraform-aws-modules/terraform-aws-vpc#inputs

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

variable "control_plane_subnets" {
  description = "Subnets for EKS control plane nodes"
  type        = list(any)
  default     = ["10.0.1.0/27", "10.0.1.32/27", "10.0.1.64/27"]
}

variable "worker_subnets" {
  description = "Subnets for EKS worker nodes"
  type        = list(any)
  default     = ["10.0.8.0/21", "10.0.16.0/21", "10.0.24.0/21"]
}

variable "public_subnets" {
  description = "Public subnets for LBs, NAT GWs and so on"
  type        = list(any)
  default     = ["10.0.100.0/23", "10.0.102.0/23", "10.0.104.0/23"]
}

variable "credentials" {
  default     = ["~/.aws/credentials"]
  description = "Where your access and secret_key are stored, you create the file when you run the aws config"
  type        = list(any)
}

variable "vpc_name" {
  description = "VPC name"
  type        = string
  default     = "my-vpc"
}

variable "enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  type        = bool
  default     = true # should be false for prod/HA purposes
}

variable "one_nat_gateway_per_az" {
  description = "Should be true if you want only one NAT Gateway per availability zone."
  type        = bool
  default     = true # should be true for prod/HA purposes
}

variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the Default VPC"
  type        = bool
  default     = true
}