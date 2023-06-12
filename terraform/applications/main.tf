provider "helm" {
  debug = true
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "aws" {
  region  = var.region
  profile = var.aws_profile
}

terraform {
  backend "s3" {
    key = "sdp-applications/terraform.tfstate"
  }
}

data "aws_secretsmanager_secret" "secrets" {
  name = "sdp/database/mongo"
}

data "aws_secretsmanager_secret_version" "current" {
  secret_id = data.aws_secretsmanager_secret.secrets.id
}

locals {
  secret = jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)
}

resource "helm_release" "mongodb_crd" {
  name = "mondodb-crd"

  repository       = "https://mongodb.github.io/helm-charts"
  chart            = "community-operator"
  namespace        = var.sdp_namespace
  create_namespace = true
}

resource "helm_release" "sdp_app" {
  name = "sdp-app"

  chart     = "../../helm/sdp-app"
  namespace = "sdp"
  version   = var.sdp_helm_version
  set {
    name  = "app.image.tag"
    value = var.sdp_docker_version
  }
  set {
    name  = "database.namespace"
    value = var.sdp_namespace
  }
  set {
    name  = "app.certificateArn"
    value = var.certificate_arn
  }
  set_sensitive {
    name  = "database.adminUsername"
    value = local.secret["admin_username"]
  }
  set_sensitive {
    name  = "database.adminPassword"
    value = local.secret["admin_password"]
  }
  set_sensitive {
    name  = "database.appUsername"
    value = local.secret["app_username"]
  }
  set_sensitive {
    name  = "database.appPassword"
    value = local.secret["app_password"]
  }
  depends_on = [helm_release.mongodb_crd]
}

module "monitoring" {
  source = "../modules/monitoring-stack"
}