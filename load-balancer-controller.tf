provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.auth.token
  }
}

# resource "null_resource" "load_balancer_target_group_bindings" {
#   count = var.install_load_balancer_controller ? 1 : 0

#   triggers = {
#     always_run = uuid()
#   }

#   provisioner "local-exec" {
#     command = <<-EOT
#        kubectl --context='${data.aws_eks_cluster.cluster.arn}' \
#         apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=v0.0.41"
#     EOT
#   }

#   depends_on = [
#     null_resource.check_aws_credentials_are_available
#   ]
# }

resource "helm_release" "load_balancer_controller" {
  count = var.install_load_balancer_controller ? 1 : 0

  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.4.5"

  values = [
    <<-EOT
      clusterName: ${var.cluster_name}
    EOT
  ]

  # depends_on = [
  #   null_resource.load_balancer_target_group_bindings
  # ]
}
