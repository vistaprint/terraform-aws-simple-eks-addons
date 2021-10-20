resource "null_resource" "container_insights" {
  count = var.install_container_insights ? 1 : 0

  triggers = {
    always_run = uuid()
  }

  # We downloaded the cwagent-fluent-bit-quickstart.yaml file from
  # https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/quickstart/cwagent-fluent-bit-quickstart.yaml
  #
  # Then, we modified that file to increase the version of aws-for-fluent-bit to 2.21.0.
  # Otherwise, logs were not reaching CloudWatch due to this bug in Fluent Bit:
  # https://github.com/fluent/fluent-bit/issues/2840
  #
  # TODO: once the file available in the GitHub repo uses version 2.21.0 or higher,
  #   let's remove the file from the data folder, and use the one in the repo instead.
  provisioner "local-exec" {
    command = <<-EOT
      cat ${path.module}/data/cwagent-fluent-bit-quickstart.yaml \
       | sed 's/{{cluster_name}}/'${data.aws_eks_cluster.cluster.name}'/;s/{{region_name}}/'${var.region}'/;s/{{http_server_toggle}}/"'On'"/;s/{{http_server_port}}/"'2020'"/;s/{{read_from_head}}/"'Off'"/;s/{{read_from_tail}}/"'On'"/' \
       | kubectl --context='${data.aws_eks_cluster.cluster.arn}' apply -f - 
    EOT
  }

  depends_on = [
    null_resource.check_aws_credentials_are_available,
    aws_cloudwatch_log_group.application,
    aws_cloudwatch_log_group.dataplane,
    aws_cloudwatch_log_group.host,
    aws_cloudwatch_log_group.performance
  ]
}

resource "aws_cloudwatch_log_group" "application" {
  count = var.install_container_insights ? 1 : 0

  name              = "/aws/containerinsights/${var.cluster_name}/application"
  retention_in_days = 90

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "dataplane" {
  count = var.install_container_insights ? 1 : 0

  name              = "/aws/containerinsights/${var.cluster_name}/dataplane"
  retention_in_days = 90

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "host" {
  count = var.install_container_insights ? 1 : 0

  name              = "/aws/containerinsights/${var.cluster_name}/host"
  retention_in_days = 90

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "performance" {
  count = var.install_container_insights ? 1 : 0

  name              = "/aws/containerinsights/${var.cluster_name}/performance"
  retention_in_days = 90

  tags = var.tags
}
