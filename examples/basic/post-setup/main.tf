terraform {
  required_version = ">= 0.13"
}

provider "aws" {}

variable "aws_region" {
  type = string
}