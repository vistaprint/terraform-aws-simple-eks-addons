resource "null_resource" "container_insights" {
  count = var.install_container_insights ? 1 : 0

  triggers = {
    always_run = uuid()
  }

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
