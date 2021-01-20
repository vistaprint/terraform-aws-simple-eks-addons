resource "null_resource" "container_insights" {
  count = var.install_container_insights ? 1 : 0

  triggers = {
    always_run = uuid()
  }

  provisioner "local-exec" {
    command = <<-EOT
      curl https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/quickstart/cwagent-fluentd-quickstart.yaml \
        | sed "s/{{cluster_name}}/${data.aws_eks_cluster.cluster.name}/;s/{{region_name}}/${var.region}/" \
        | kubectl --context='${data.aws_eks_cluster.cluster.arn}' apply -f -
    EOT
  }

  depends_on = [
    null_resource.check_aws_credentials_are_available
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
