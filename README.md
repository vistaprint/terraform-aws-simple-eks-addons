# Simple EKS Add-Ons Module

This module manages several add-ons that might be needed in an EKS cluster. It currently supports the following add-ons:

- Metrics server
- AWS Container Insights agent installation
- Cluster autoscaling
- Ingress controller

Ideally this module should not be necessary, and all these add-ons could be installed from the `simple-eks` module itself. But, the Terraform provider for Kubernetes has some limitations that prevented us from doing so. In short, the Kubernetes provider cannot be initialized with credentials obtained in the same `terraform apply` execution where the cluster is created. (See the warning box in https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs#stacking-with-managed-kubernetes-cluster-resources for more details).

## References

- [Cluster autoscaler](https://docs.aws.amazon.com/eks/latest/userguide/cluster-autoscaler.html)
- [Metrics server](https://docs.aws.amazon.com/eks/latest/userguide/metrics-server.html)
- [AWS Container Insights agent](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/deploy-container-insights-EKS.html)
- [Ingress controller](https://github.com/kubernetes/ingress-nginx)
- [Ingress controller Helm package](https://kubernetes.github.io/ingress-nginx/deploy/#using-helm)

### Calico

- https://kubernetes.github.io/ingress-nginx/deploy/baremetal/#via-the-host-network
