# Simple EKS Add-Ons Module

This module manages several add-ons that might be needed in an EKS cluster. It currently supports the following add-ons:

- Metrics server
- AWS Container Insights agent installation
- Cluster autoscaling
- AWS Load Balancer Controller

Ideally this module should not be necessary, and all these add-ons could be installed from the `simple-eks` module itself. But, the Terraform provider for Kubernetes has some limitations that prevented us from doing so. In short, the Kubernetes provider cannot be initialized with credentials obtained in the same `terraform apply` execution where the cluster is created. (See the warning box in <https://registry.terraform.io/providers/hashicorp/kubernetes/latest/> docs#stacking-with-managed-kubernetes-cluster-resources for more details).

## Development

### Update Metrics Server

When updating to a newer version of the metrics server, the container arguments need to be changed as shown below.

From:

```yaml
- args:
    - --cert-dir=/tmp
    - --secure-port=443
    - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
    - --kubelet-use-node-status-port
    - --metric-resolution=15s
```

To:

```yaml
- args:
    - --cert-dir=/tmp
    - --secure-port=443
    - --kubelet-preferred-address-types=InternalIP
    - --kubelet-use-node-status-port
    - --metric-resolution=15s
    - --kubelet-insecure-tls
```

Also, add `hostNetwork: ${host_network}` to the template spec.

## References

- [Cluster autoscaler](https://docs.aws.amazon.com/eks/latest/userguide/cluster-autoscaler.html)
- [Metrics server](https://docs.aws.amazon.com/eks/latest/userguide/metrics-server.html)
- [AWS Container Insights agent](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/deploy-container-insights-EKS.html)
- [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/)
- [AWS Load Balancer Controller Helm package](https://github.com/aws/eks-charts/tree/master/stable/aws-load-balancer-controller)

### Calico

- <https://kubernetes.github.io/ingress-nginx/deploy/baremetal/#via-the-host-network>
