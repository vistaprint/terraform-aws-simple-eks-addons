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

variable "install_load_balancer_controller" {
  type    = bool
  default = false
}

variable "install_metrics_server" {
  type    = bool
  default = false
}

variable "enable_cluster_autoscaler" {
  type    = bool
  default = false
}
