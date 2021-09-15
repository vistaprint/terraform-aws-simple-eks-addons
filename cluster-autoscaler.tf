data "external" "cluster_autoscaler_version" {
  count = var.enable_cluster_autoscaler ? 1 : 0

  program = ["bash", "${path.module}/cluster-autoscaler-version.sh", data.aws_eks_cluster.cluster.version]
}

resource "null_resource" "cluster_autoscaler" {
  count = var.enable_cluster_autoscaler ? 1 : 0

  triggers = {
    always_run = uuid()
    yaml = replace(
      replace(
        file("${path.module}/data/cluster-autoscaler-autodiscover.yaml"),
        "<YOUR CLUSTER NAME>",
        var.cluster_name
      ),
      "<CLUSTER AUTOSCALER VERSION>",
      data.external.cluster_autoscaler_version.0.result["version"]
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
