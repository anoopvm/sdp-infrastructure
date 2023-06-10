locals {
  service_account_name = "aws-load-balancer-controller"
  namespace            = "kube-system"
}

resource "aws_iam_policy" "this" {
  name   = "eks_alb.ingress"
  policy = file("${path.module}/templates/alb-ingress-policy.json")
}

# TODO: rewrite with declarative implementation 
# (role creation + service account)
# based on https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.5/deploy/installation/#option-a-recommended-iam-roles-for-service-accounts-irsa
resource "null_resource" "role_service_account" {
  provisioner "local-exec" {
    command = <<EOT
          eksctl create iamserviceaccount \
            --cluster=${var.cluster_name} \
            --namespace=${local.namespace} \
            --name=${local.service_account_name} \
            --attach-policy-arn=${aws_iam_policy.this.arn} \
            --override-existing-serviceaccounts \
            --region ${var.region} \
            --approve
    EOT
  }
}

resource "helm_release" "eks_alb_ingress" {
  name = "eks-alb-ingress"

  repository   = "https://aws.github.io/eks-charts"
  chart        = "aws-load-balancer-controller"
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
