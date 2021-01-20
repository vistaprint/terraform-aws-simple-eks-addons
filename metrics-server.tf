resource "null_resource" "metrics_server" {
  count = var.install_metrics_server ? 1 : 0

  triggers = {
    always_run = uuid()
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo '${data.template_file.metrics_server.rendered}' |
        kubectl --context='${data.aws_eks_cluster.cluster.arn}' apply -f -
    EOT
  }

  depends_on = [
    null_resource.check_aws_credentials_are_available
  ]
}

data "template_file" "metrics_server" {
  template = file("${path.module}/data/metrics-server.tpl.yaml")

  vars = {
    host_network = var.use_calico_cni
  }
}
