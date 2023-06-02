data "aws_availability_zones" "available" {}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

locals {
  cluster_name          = "my-eks-${random_string.suffix.result}"
  control_plane_subnets = ["10.0.1.0/28", "10.0.1.16/28", "10.0.1.32/28"]
  worker_subnets        = ["10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24"]
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "my-vpc"

  cidr = "10.0.0.0/16"
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  # private_subnets = ["10.0.1.0/28", "10.0.1.16/28", "10.0.1.32/28", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24"]
  private_subnets = concat(local.control_plane_subnets, local.worker_subnets)
  public_subnets  = ["10.0.100.0/24", "10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true
  enable_dns_hostnames   = true

  # tags needed for AWS LB Controller
  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
  }
}