variable "region" {
  type    = string
  default = "us-east-1"
}

variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "app_tier_subnet_ids" {
  type = list(any)
}

variable "data_tier_subnet_ids" {
  type = list(any)
}


variable "public_subnet_ids" {
  type = list(any)
}

variable "public_access_ips" {
  type = list(any)
}

variable "tags" {
  type = map
}
