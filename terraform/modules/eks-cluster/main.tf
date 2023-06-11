
locals {
  cluster_version        = "1.27"
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
}

provider "kubernetes" {
  host                   = local.host
  cluster_ca_certificate = local.cluster_ca_certificate

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = local.host
    cluster_ca_certificate = local.cluster_ca_certificate
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", var.region]
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}
data "aws_ami" "eks_ami" {
  owners           = ["self"]
  filter {
    name = "name"
    values = ["${var.ami_name}-${var.ami_version}"]
  }
}

module "ebs_csi_role" {
  source = "../eks_role"

  name = "eks-ebs-csi-driver"
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider = module.eks.oidc_provider
}

module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name                   = var.name
  cluster_version                = local.cluster_version
  cluster_endpoint_public_access = true
  cluster_endpoint_public_access_cidrs = var.public_access_ips

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      service_account_role_arn = module.ebs_csi_role.role_arn
      most_recent              = true
    }
  }

  vpc_id                   = var.vpc_id
  subnet_ids               = concat(var.app_tier_subnet_ids, var.data_tier_subnet_ids)

  create_aws_auth_configmap = true
  manage_aws_auth_configmap = true

  self_managed_node_group_defaults = {
    autoscaling_group_tags = {
      "k8s.io/cluster-autoscaler/enabled" : true,
      "k8s.io/cluster-autoscaler/${var.name}" : "owned",
    }
    iam_role_additional_policies = {
      AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      EbsCsiPolicy                 = module.ebs_csi_role.policy_arn
    }
  }

  self_managed_node_groups = {
    frontend = {
      name = "frontend"

      max_size     = 3
      desired_size = 2
      min_size     = 1
      subnet_ids = var.app_tier_subnet_ids
      ami_id        = data.aws_ami.eks_ami.image_id
      bootstrap_extra_args = "--kubelet-extra-args '--node-labels=tier=app'"
    },
    database = {
      name = "database"

      max_size     = 4
      desired_size = 3
      min_size     = 1
      subnet_ids   = var.data_tier_subnet_ids
      ami_id        = data.aws_ami.eks_ami.image_id
      bootstrap_extra_args = "--kubelet-extra-args '--node-labels=tier=data'"
    }
  }
  tags = var.tags
}

#module "eks-alb-ingress" {
#  source  = "lablabs/eks-alb-ingress/aws"
#  version = "0.6.0":w
#  
#  cluster_identity_oidc_issuer = module.eks.cluster_oidc_issuer_url
#  cluster_identity_oidc_issuer_arn = module.eks.oidc_provider_arn
#  cluster_name = module.eks.cluster_name
#  enabled = true
#
#  settings = {
#    "awsVpcID": var.vpc_id
#    "awsRegion": var.region
#    "clusterName": module.eks.cluster_name  
#  }
#}

#resource "helm_release" "eks_alb_ingress" {
#  name = "eks-alb-ingress"
#  repository = "https://cloudnativeapp.github.io/charts/curated/"
#  chart = "aws-alb-ingress-controller"
#}

resource "aws_ec2_tag" "all_subnets" {
  for_each    = {
    for idx, id in concat(var.app_tier_subnet_ids, var.data_tier_subnet_ids, var.public_subnet_ids):
    idx => id
  }

  resource_id = each.value
  key         = "kubernetes.io/cluster/${module.eks.cluster_name}"
  value       = "shared"
}

resource "aws_ec2_tag" "public_subnets" {
  for_each = toset(var.public_subnet_ids)

  resource_id = each.value
  key         = "kubernetes.io/role/elb"
  value       = ""
}

resource "aws_ec2_tag" "private_subnets" {
  for_each    = {
    for idx, id in concat(var.app_tier_subnet_ids, var.data_tier_subnet_ids):
    idx => id
  }

  resource_id = each.value
  key         = "kubernetes.io/role/internal-elb"
  value       = ""
}

module "alb-ingress-controller" {
  source = "../eks-ingress"

  region       = var.region
  cluster_name = module.eks.cluster_name
}