locals {
  public_endpoints       = var.publish_strategy == "External" ? true : false
  description            = "Created By AAP Installer"

  allow_expansion_zones  = length(var.availability_zones) == 1 ? 1 : 0

  cidr_dedicated_private = cidrsubnet(data.aws_vpc.cluster_vpc.cidr_block, 1, 0)
  cidr_dedicated_public  = cidrsubnet(data.aws_vpc.cluster_vpc.cidr_block, 1, 1)

  new_private_cidr_range      = cidrsubnet(local.cidr_dedicated_private, local.allow_expansion_zones, 0)
  new_public_cidr_range  = cidrsubnet(local.cidr_dedicated_public, local.allow_expansion_zones, 0)
}

data "aws_vpc" "cluster_vpc" {
  id = var.vpc == null ? aws_vpc.new_vpc[0].id : var.vpc
}

data "aws_subnet" "private" {
  count = var.private_subnets == null ? length(var.availability_zones) : length(var.private_subnets)

  id = var.private_subnets == null ? aws_subnet.private_subnet[count.index].id : var.private_subnets[count.index]
}

data "aws_subnet" "public" {
  count = var.public_subnets == null ? length(var.availability_zones) : length(var.public_subnets)

  id = var.public_subnets == null ? aws_subnet.public_subnet[count.index].id : var.public_subnets[count.index]
}