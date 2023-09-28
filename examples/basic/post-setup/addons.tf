module "addons" {
  source = "../../.."

  region = var.aws_region

  cluster_name = local.cluster_name

  load_balancer_controller = {
    enabled       = true
    chart_version = "1.6.1"
    image_tag     = "v2.6.1"
  }
  metrics_server = {
    enabled       = true
    chart_version = "3.11.0"
    image_tag     = "v0.6.4"
  }
  cluster_autoscaler = {
    enabled       = true
    chart_version = "9.29.3"
    image_tag     = "v1.27.2"
  }
}
