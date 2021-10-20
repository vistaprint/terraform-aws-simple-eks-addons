module "cluster" {
  source  = "vistaprint/simple-eks/aws"
  version = "0.3.5"

  cluster_name    = "simple-eks-integration-test-for-eks-addons"
  cluster_version = "1.21"
  vpc_name        = var.vpc_name

  region  = var.aws_region
  profile = var.aws_profile
}

module "on_demand_node_group" {
  source  = "vistaprint/simple-eks-node-group/aws"
  version = "0.5.2"

  cluster_name       = "simple-eks-integration-test-for-eks-addons"
  node_group_name    = "on-demand"
  node_group_version = "1.21"

  instance_types = ["t3a.medium"]

  scaling_config = {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  worker_role_arn = module.cluster.worker_role_arn
  subnet_ids      = module.cluster.private_subnet_ids

  region  = var.aws_region
  profile = var.aws_profile

  depends_on = [module.cluster]
}
