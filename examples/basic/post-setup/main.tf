terraform {
  required_version = ">= 1.3"
}

provider "aws" {}

variable "aws_region" {
  type = string
}