resource "null_resource" "cluster_autoscaler" {
  count = var.enable_cluster_autoscaler ? 1 : 0

  triggers = {
    always_run = uuid()
    yaml = replace(
      file("${path.module}/data/cluster-autoscaler-autodiscover.yaml"),
      "<YOUR CLUSTER NAME>",
      var.cluster_name
    )
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo '${self.triggers.yaml}' | kubectl --context='${data.aws_eks_cluster.cluster.arn}' apply -f -
    EOT
  }

  depends_on = [
    null_resource.check_aws_credentials_are_available
  ]
}
