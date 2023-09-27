# Simple EKS Add-Ons Module

This module manages several add-ons that might be needed in an EKS cluster. It currently supports the following add-ons:

- Metrics server
- Cluster autoscaling
- AWS Load Balancer Controller

Ideally this module should not be necessary, and all these add-ons could be installed from the `simple-eks` module itself. But, the Terraform provider for Kubernetes has some limitations that prevented us from doing so. In short, the Kubernetes provider cannot be initialized with credentials obtained in the same `terraform apply` execution where the cluster is created. (See the warning box in <https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs#stacking-with-managed-kubernetes-cluster-resources> for more details).

## Development

### Testing

We use [Terratest](https://github.com/gruntwork-io/terratest) to run integration tests.

Before running the tests the following environment variables must be set:

- AWS_PROFILE: the AWS profile to use for the test
- AWS_DEFAULT_REGION: region where the test cluster will be created (try to use a region other than eu-west-1, ie eu-west-2)
- SIMPLE_EKS_TEST_VPC_NAME: VPC to be used by the test cluster

Then, go into `test` folder and run:

```shell
go test -v -timeout 30m
```

## References

- [Cluster autoscaler](https://docs.aws.amazon.com/eks/latest/userguide/cluster-autoscaler.html)
- [Metrics server](https://docs.aws.amazon.com/eks/latest/userguide/metrics-server.html)
- [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/)
- [AWS Load Balancer Controller Helm package](https://github.com/aws/eks-charts/tree/master/stable/aws-load-balancer-controller)
