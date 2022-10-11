# resource "null_resource" "metrics_server" {
#   count = var.install_metrics_server ? 1 : 0

#   triggers = {
#     always_run = uuid()
#   }

#   provisioner "local-exec" {
#     command = <<-EOT
#       echo '${data.template_file.metrics_server.rendered}' |
#         kubectl --context='${data.aws_eks_cluster.cluster.arn}' apply -f -
#     EOT
#   }

#   depends_on = [
#     null_resource.check_aws_credentials_are_available
#   ]
# }

# data "template_file" "metrics_server" {
#   template = file("${path.module}/data/metrics-server.tpl.yaml")

#   vars = {
#     # host_network = var.use_calico_cni
#     host_network = false
#   }
# }

resource "helm_release" "metrics_server" {
  count = var.install_metrics_server ? 1 : 0

  name       = "metrics-server"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/metrics-server"
  chart      = "metrics-server"
  version    = "3.8.2"
}
