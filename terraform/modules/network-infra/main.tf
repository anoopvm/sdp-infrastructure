provider "aws" {
  # Ignore tags added by kubernetes module
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/guides/resource-tagging#ignoring-changes-in-all-resources
  ignore_tags {
    key_prefixes = ["kubernetes.io/"]
  }
}

locals {
  tiers = ["app-tier", "data-tier"]
  private_subnet_names = [ for item in setproduct(local.tiers, var.azs): "${var.name}-${item[0]}-${item[1]}-private"]
  
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.name
  cidr = var.cidr

  azs             = var.azs
  private_subnets = concat(var.app_tier_private_subnets, var.data_tier_private_subnets)
  private_subnet_names = local.private_subnet_names
  public_subnets  = var.public_subnets

  enable_nat_gateway = true
  single_nat_gateway = true
  tags = var.tags
}
