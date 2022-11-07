module "addons" {
  source = "../../.."

  region = var.aws_region

  cluster_name = "simple-eks-integration-test-for-eks-addons"

  load_balancer_controller = {
    enabled = true
  }
  metrics_server = {
    enabled = true
  }
  cluster_autoscaler = {
    enabled = true
  }
}
