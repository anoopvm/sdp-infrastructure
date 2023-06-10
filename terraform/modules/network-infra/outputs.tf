output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets_cidr_blocks" {
  value = module.vpc.public_subnets_cidr_blocks
}

output "private_subnets_cidr_blocks" {
  value = module.vpc.private_subnets_cidr_blocks
}

output "public_subnets_ids" {
  value = module.vpc.public_subnets
}

output "app_tier_private_subnets_ids" {
  value = slice(module.vpc.private_subnets, 0, length(var.app_tier_private_subnets))
}

output "data_tier_private_subnets_ids" {
  value = slice(module.vpc.private_subnets, length(var.app_tier_private_subnets), length(module.vpc.private_subnets))
}
