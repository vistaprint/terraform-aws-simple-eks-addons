provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.auth.token
  }
}

locals {
  crds_tag = (try(var.load_balancer_controller.image_tag) == null
    ? "master"
    : var.load_balancer_controller.image_tag
  )
}

resource "null_resource" "load_balancer_target_group_bindings" {
  count = try(var.load_balancer_controller.enabled) == true ? 1 : 0

  triggers = {
    always_run = uuid()
  }

  provisioner "local-exec" {
    command = <<-EOT
       kubectl --context='${data.aws_eks_cluster.cluster.arn}' \
        apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=${local.crds_tag}"
    EOT
  }

  depends_on = [
    null_resource.check_aws_credentials_are_available
  ]
}

resource "helm_release" "load_balancer_controller" {
  count = try(var.load_balancer_controller.enabled) == true ? 1 : 0

  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = var.load_balancer_controller.chart_version

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  dynamic "set" {
    for_each = var.load_balancer_controller.image_tag != null ? [1] : []

    content {
      name  = "image.tag"
      value = var.load_balancer_controller.image_tag
    }
  }

  depends_on = [
    null_resource.load_balancer_target_group_bindings
  ]
}
