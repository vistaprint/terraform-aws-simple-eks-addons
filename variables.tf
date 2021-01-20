variable "region" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "ingress" {
  type = object({
    cluster_zone    = string
    wildcard_domain = string
  })
  default = null
}

variable "install_metrics_server" {
  type    = bool
  default = false
}

variable "install_container_insights" {
  type    = bool
  default = false
}

variable "enable_cluster_autoscaler" {
  type    = bool
  default = false
}

variable "use_calico_cni" {
  type    = bool
  default = false
}
