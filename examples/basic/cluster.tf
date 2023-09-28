module "cluster" {
  source  = "vistaprint/simple-eks/aws"
  version = "0.4.0"

  cluster_name    = local.cluster_name
  cluster_version = "1.27"
  vpc_name        = var.vpc_name

  region  = var.aws_region
  profile = var.aws_profile
}

module "on_demand_node_group" {
  source  = "vistaprint/simple-eks-node-group/aws"
  version = "0.6.0"

  cluster_name       = local.cluster_name
  node_group_name    = "on-demand"
  node_group_version = "1.27"

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
