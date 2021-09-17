module "addons" {
  source = "../../.."

  region  = var.aws_region

  cluster_name = "simple-eks-integration-test-for-eks-addons"

  install_load_balancer_controller = true
  install_metrics_server           = true
  install_container_insights       = true
  enable_cluster_autoscaler        = true

  use_calico_cni = true
}