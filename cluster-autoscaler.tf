data "external" "cluster_autoscaler_version" {
  count = try(var.cluster_autoscaler.enabled) == true ? 1 : 0

  program = ["bash", "${path.module}/cluster-autoscaler-version.sh", data.aws_eks_cluster.cluster.version]
}

resource "helm_release" "cluster_autoscaler" {
  count = try(var.cluster_autoscaler.enabled) == true ? 1 : 0

  name       = "cluster-autoscaler"
  namespace  = "kube-system"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  version    = var.cluster_autoscaler.chart_version

  set {
    name  = "image.tag"
    value = var.cluster_autoscaler.image_tag != null ? var.cluster_autoscaler.image_tag : "v${data.external.cluster_autoscaler_version[0].result["version"]}"
  }

  set {
    name  = "autoDiscovery.clusterName"
    value = var.cluster_name
  }

  set {
    name  = "awsRegion"
    value = var.region
  }
}
