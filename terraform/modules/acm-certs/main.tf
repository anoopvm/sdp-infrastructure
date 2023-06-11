module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name = "anoopmuraleedharan.com"
  #zone_id      = "Z2ES7B9AZ6SHAE"
  create_route53_records = false

  subject_alternative_names = [
    "*.anoopmuraleedharan.com"
  ]

  wait_for_validation = true

  tags = {
    Name = "anoopmuraleedharan.com"
  }
}