resource "helm_release" "mongo-db-crd" {
  name = "mongo-db-crd"

  repository   = "https://mongodb.github.io/helm-charts"
  chart        = "community-operator"
  namespace    = "kube-system"
  force_update = true
  set {
    name  = "clusterName"
    value = var.cluster_name
  }
  set {
    name  = "serviceAccount.create"
    value = false
  }
  set {
    name  = "serviceAccount.name"
    value = local.service_account_name
  }

}