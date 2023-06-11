locals {
  version    = "v0.0.2"
  image_name = "eks-instance-${local.version}"
}

packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "eks_instance" {
  ami_name      = local.image_name
  instance_type = "m6i.large"
  region        = "us-east-1"
  source_ami_filter {
    filters = {
      name                = "amazon-eks-node-1.27-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["602401143452"]
  }
  ssh_username = "ec2-user"
}

build {

  sources = [
    "source.amazon-ebs.eks_instance"
  ]

  provisioner "shell" {
    inline = [
      "echo disable chronyd.service",
      "sudo systemctl stop chronyd.service",
      "sudo systemctl disable chronyd.service",
      "sudo yum -y update",
      "sudo yum install -y ntp",
      "sudo systemctl enable ntpd.service",
      "sudo systemctl start ntpd.service"
    ]
  }
}
