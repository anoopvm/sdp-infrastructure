region = "us-east-1"
tags = {
  Terraform        = "true"
  billing_category = "default"
}

## Network Infra Configs
vpc_name                  = "staging-sdp"
cidr                      = "10.0.0.0/16"
azs                       = ["us-east-1a", "us-east-1b"]
app_tier_private_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
data_tier_private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]
public_subnets            = ["10.0.101.0/24", "10.0.102.0/24"]

## EKS Variables
ami_name        = "eks-instance"
ami_version     = "v0.0.2"
eks_name          = "staging-sdp"
public_access_ips = ["68.82.59.182/32"]
