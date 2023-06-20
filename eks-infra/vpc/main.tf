data "aws_availability_zones" "available" {}

locals {
  control_plane_subnets = var.control_plane_subnets
  worker_subnets        = var.worker_subnets
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = var.vpc_name

  cidr = var.vpc_cidr
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  private_subnets = concat(local.control_plane_subnets, local.worker_subnets)
  public_subnets  = var.public_subnets

  enable_nat_gateway     = var.enable_nat_gateway
  single_nat_gateway     = var.single_nat_gateway
  one_nat_gateway_per_az = var.one_nat_gateway_per_az
  enable_dns_hostnames   = var.enable_dns_hostnames

  # tags needed for AWS LB Controller
  # https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.5/deploy/subnet_discovery/
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}