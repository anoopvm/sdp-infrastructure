terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.1.0"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = var.aws_profile
}

terraform {
  backend "s3" {
    key = "sdp-infrastructure/terraform.tfstate"
  }
}

module "network_infra" {
  source = "../modules/network-infra"

  name                      = var.vpc_name
  cidr                      = var.cidr
  azs                       = var.azs
  app_tier_private_subnets  = var.app_tier_private_subnets
  data_tier_private_subnets = var.data_tier_private_subnets
  public_subnets            = var.public_subnets
  tags                      = var.tags
}

module "eks-cluster" {
  source = "../modules/eks-cluster"

  name                 = var.eks_name
  region               = var.region
  vpc_id               = module.network_infra.vpc_id
  app_tier_subnet_ids  = module.network_infra.app_tier_private_subnets_ids
  data_tier_subnet_ids = module.network_infra.data_tier_private_subnets_ids
  public_subnet_ids    = module.network_infra.public_subnets_ids
  public_access_ips    = var.public_access_ips
  ami_name             = var.ami_name
  ami_version          = var.ami_version
  tags                 = var.tags
}
