variable "name" {
  type = string
}

variable "cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "azs" {
  type    = list(any)
  default = ["us-east-1a", "us-east-1b"]
}

variable "app_tier_private_subnets" {
  type    = list(any)
}

variable "data_tier_private_subnets" {
  type    = list(any)
}

variable "public_subnets" {
  type    = list(any)
}

variable "tags" {
  type = map(any)
  default = {
    Terraform        = "true"
    billing_category = "default"
  }
}