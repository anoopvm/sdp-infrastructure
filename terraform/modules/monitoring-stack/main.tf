locals {
  namespace = "monitoring"
}

resource "helm_release" "prometheus" {
  name = "prometheus"

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  namespace  = local.namespace
  create_namespace = true
  #values     = ["../config/prom-values.yaml"]
}

resource "helm_release" "grafana" {
  name = "grafana"

  repository = "https://grafana.github.io/helm-charts"
  chart = "grafana"
  namespace = local.namespace
  create_namespace = true
  values = [
    "${file("${path.module}/configs/datasources.yaml")}",
    "${file("${path.module}/configs/dashboards.yaml")}"
  ]
}

resource "helm_release" "ingress" {
  name = "monitoring-ingress"

  chart = "${path.module}/../../../helm/ingress/"
  namespace = local.namespace
  create_namespace = true
  version = "0.1.1"

  values = [
    "${file("${path.module}/configs/ingress.yaml")}"
  ]
  set {
    name = "namespace"
    value = local.namespace
  }
}