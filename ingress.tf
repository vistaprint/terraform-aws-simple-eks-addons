provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.auth.token
  }
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.auth.token
  load_config_file       = false
}

resource "helm_release" "ingress" {
  count = var.ingress == null ? 0 : 1

  name             = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "3.16.1"

  # See next link for information on how to do TLS-termination:
  # https://github.com/kubernetes/ingress-nginx/blob/7772c2ac64d7cf965ead974fc259a12c01221e52/hack/generate-deploy-scripts.sh#L90-L123

  # Using Calico CNI creates a series of issues that need to be addressed.
  # These docs (https://kubernetes.github.io/ingress-nginx/deploy/baremetal/#via-the-host-network) were used to find out which bits need to be changed.
  values = [
    <<-EOT
      controller:
        replicaCount: ${var.use_calico_cni ? 1 : 2}
        minAvailable: 1
        autoscaling:
          enabled: ${!var.use_calico_cni}
          minReplicas: 2
          maxReplicas: 4

        hostNetwork: ${var.use_calico_cni}
        dnsPolicy: ${var.use_calico_cni ? "ClusterFirstWithHostNet" : "ClusterFirst"}

        extraArgs:
          disable-catch-all: false

        containerPort:
          http: 80
          https: 443
          tohttps: 2443

        config:
          proxy-real-ip-cidr: ${data.aws_vpc.eks_vpc[0].cidr_block}
          use-forwarded-headers: "true"
          ssl-redirect: "false" # we use `tohttps` port to control ssl redirection
          http-snippet: |
            server {
              listen 2443;
              return 308 https://$host$request_uri;
            }

        service:
          type: LoadBalancer
          externalTrafficPolicy: Local

          annotations:
            service.beta.kubernetes.io/aws-load-balancer-backend-protocol: http
            service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: "true"
            service.beta.kubernetes.io/aws-load-balancer-ssl-ports: "https"
            service.beta.kubernetes.io/aws-load-balancer-ssl-cert: "${data.aws_acm_certificate.cert[0].arn}"
            service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
            service.beta.kubernetes.io/aws-load-balancer-connection-idle-timeout: "60"

          targetPorts:
            http: tohttps
            https: http
    EOT
  ]
}

data "aws_vpc" "eks_vpc" {
  count = var.ingress == null ? 0 : 1

  id = data.aws_eks_cluster.cluster.vpc_config[0].vpc_id
}

data "aws_acm_certificate" "cert" {
  count = var.ingress == null ? 0 : 1

  domain = var.ingress.wildcard_domain
  types  = ["AMAZON_ISSUED"]
}

data "aws_route53_zone" "cluster" {
  count = var.ingress == null ? 0 : 1

  name = var.ingress.cluster_zone
}

resource "null_resource" "wait_for_elb" {
  count = var.ingress == null ? 0 : 1

  triggers = {
    chart     = helm_release.ingress.0.metadata[0].chart
    name      = helm_release.ingress.0.metadata[0].name
    namespace = helm_release.ingress.0.metadata[0].namespace
    version   = helm_release.ingress.0.metadata[0].version
    values    = helm_release.ingress.0.metadata[0].values
  }

  provisioner "local-exec" {
    command = <<-EOT
      timeout 300 sh -c 'while true; do
        grep "elb.${var.region}.amazonaws.com" <<<$(
          kubectl --context='${data.aws_eks_cluster.cluster.arn}' \
            -n ${self.triggers.namespace} \
            get service ${self.triggers.name}-controller \
            -o jsonpath="{.status.loadBalancer.ingress[0].hostname}"
          )
        if [ $? -eq 0 ]; then
          break
        else
          exit 1
        fi
        sleep 1
      done' || false
    EOT

    interpreter = ["bash", "-c"]
  }
}

data "kubernetes_service" "ingress_controller" {
  count = var.ingress == null ? 0 : 1

  metadata {
    name      = "${helm_release.ingress.0.metadata[0].name}-controller"
    namespace = helm_release.ingress.0.metadata[0].namespace
  }

  depends_on = [null_resource.wait_for_elb.0]
}

data "aws_lb" "ingress" {
  count = var.ingress == null ? 0 : 1

  name = split(
    "-",
    data.kubernetes_service.ingress_controller.0.load_balancer_ingress.0.hostname
  )[0]
}

resource "aws_route53_record" "cluster_domain" {
  count = var.ingress == null ? 0 : 1

  zone_id = data.aws_route53_zone.cluster.0.zone_id
  name    = "${data.aws_eks_cluster.cluster.name}.${data.aws_route53_zone.cluster.0.name}"
  type    = "A"

  alias {
    name                   = data.aws_lb.ingress.0.dns_name
    zone_id                = data.aws_lb.ingress.0.zone_id
    evaluate_target_health = false
  }
}
