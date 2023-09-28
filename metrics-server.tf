resource "helm_release" "metrics_server" {
  count = try(var.metrics_server.enabled, null) == true ? 1 : 0

  name       = "metrics-server"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/metrics-server"
  chart      = "metrics-server"
  version    = var.metrics_server.chart_version

  dynamic "set" {
    for_each = var.metrics_server.image_tag != null ? [1] : []

    content {
      name  = "image.tag"
      value = var.metrics_server.image_tag
    }
  }
}
