variable "region" {
  type    = string
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

variable "ami_name" {
  type = string
}

variable "ami_version" {
  type = string
}
