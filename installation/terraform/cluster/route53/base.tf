locals {

  // Because of the issue https://github.com/hashicorp/terraform/issues/12570, the consumers cannot count 0/1
  // based on if controller_external_lb_dns_name for example, which will be null when there is no external lb for API.
  // So publish_strategy serves an coordinated proxy for that decision.
  public_endpoints = var.publish_strategy == "External" ? true : false

}

provider "aws" {
  alias = "private_hosted_zone"

  region = var.region

  skip_region_validation = true

#   endpoints {
#     ec2     = lookup(var.custom_endpoints, "ec2", null)
#     elb     = lookup(var.custom_endpoints, "elasticloadbalancing", null)
#     iam     = lookup(var.custom_endpoints, "iam", null)
#     route53 = lookup(var.custom_endpoints, "route53", null)
#     s3      = lookup(var.custom_endpoints, "s3", null)
#     sts     = lookup(var.custom_endpoints, "sts", null)
#   }
}

data "aws_route53_zone" "public" {
  count = local.public_endpoints ? 1 : 0

  name = var.base_domain

  depends_on = [aws_route53_record.controller_external_internal_zone_alias]
}

data "aws_route53_zone" "int" {
  provider = aws.private_hosted_zone

  zone_id = var.internal_zone == null ? aws_route53_zone.new_int[0].id : var.internal_zone
}

resource "aws_route53_zone" "new_int" {
  count = var.internal_zone == null ? 1 : 0

  name          = var.cluster_domain
  force_destroy = true

  vpc {
    vpc_id = var.vpc_id
  }

  tags = merge(
    {
      "Name" = "${var.cluster_id}-int"
    },
    var.tags,
  )
}

resource "aws_route53_record" "controller_external_alias" {
  count = local.public_endpoints ? 1 : 0

  zone_id = data.aws_route53_zone.public[0].zone_id
  name    = "controller.${var.cluster_domain}"
  type    = "A"

  alias {
    name                   = var.controller_external_lb_dns_name
    zone_id                = var.controller_external_lb_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "controller_internal_alias" {
  provider = aws.private_hosted_zone

  zone_id = data.aws_route53_zone.int.zone_id
  name    = "controller-int.${var.cluster_domain}"
  type    = "A"

  alias {
    name                   = var.controller_internal_lb_dns_name
    zone_id                = var.controller_internal_lb_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "controller_external_internal_zone_alias" {
  provider = aws.private_hosted_zone

  zone_id = data.aws_route53_zone.int.zone_id
  name    = "controller.${var.cluster_domain}"
  type    = "A"

  alias {
    name                   = var.controller_internal_lb_dns_name
    zone_id                = var.controller_internal_lb_zone_id
    evaluate_target_health = false
  }
}
