locals {
  monitoring_namespace    = var.install_monitoring_stack ? "monitoring" : ""
  grafana_service_name    = var.install_monitoring_stack ? "monitoring-grafana" : ""
  prometheus_service_name = var.install_monitoring_stack ? "monitoring-kube-prometheus-prometheus" : ""
}

resource "kubernetes_namespace" "monitoring" {
  count = var.install_monitoring_stack ? 1 : 0

  metadata {
    name = local.monitoring_namespace
  }
}

resource "helm_release" "kube_prometheus_stack" {
  count      = var.install_monitoring_stack ? 1 : 0
  name       = "kube-prom-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "65.0.0"
  namespace  = local.monitoring_namespace

  values = [
    jsonencode({
      grafana = {
        service = { type = "LoadBalancer" }
      }
      prometheus = {
        service = { type = "LoadBalancer" }
      }
    })
  ]

  depends_on = [
    aws_eks_node_group.main,
    aws_eks_access_policy_association.jenkins_cluster_admin,
    kubernetes_namespace.monitoring
  ]
}
