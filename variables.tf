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

variable "load_balancer_controller" {
  type = object({
    enabled       = bool
    chart_version = optional(string)
    image_tag     = optional(string)
  })
  default = null
}

variable "metrics_server" {
  type = object({
    enabled       = bool
    chart_version = optional(string)
    image_tag     = optional(string)
  })
  default = null
}

variable "cluster_autoscaler" {
  type = object({
    enabled       = bool
    chart_version = optional(string)
    image_tag     = optional(string)
  })
  default = null
}
