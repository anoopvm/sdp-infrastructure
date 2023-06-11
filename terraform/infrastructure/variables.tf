variable "vpc_name" {
  type = string
}

variable "region" {
  type = string
}

variable "cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "azs" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "app_tier_private_subnets" {
  type = list(any)
}

variable "data_tier_private_subnets" {
  type = list(any)
}

variable "public_subnets" {
  type    = list(any)
  default = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "public_access_ips" {
  type = list(any)
}

variable "ami_name" {
  type = string
}

variable "ami_version" {
  type = string
}

variable "tags" {
  type = map(any)
  default = {
    Terraform        = "true"
    billing_category = "default"
  }
}

variable "eks_name" {
  type = string
}