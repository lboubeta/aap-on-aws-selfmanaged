locals {
  tags = merge(
    {
      "aap/cluster/${var.cluster_id}" = "owned"
    },
    var.aws_extra_tags,
  )
  description    = "Created By AAP Installer"
  new_tag_len    = 8
  sliced_tag_map = length(var.aws_extra_tags) <= local.new_tag_len ? var.aws_extra_tags : { for k in slice(keys(var.aws_extra_tags), 0, local.new_tag_len) : k => var.aws_extra_tags[k] }
  s3_object_tags = merge(
    {
      "aap/cluster/${var.cluster_id}" = "owned"
    },
    local.sliced_tag_map,
  )
}

provider "aws" {
  region = var.aws_region

  skip_region_validation = true

  # endpoints {
  #   ec2     = lookup(var.custom_endpoints, "ec2", null)
  #   elb     = lookup(var.custom_endpoints, "elasticloadbalancing", null)
  #   iam     = lookup(var.custom_endpoints, "iam", null)
  #   route53 = lookup(var.custom_endpoints, "route53", null)
  #   s3      = lookup(var.custom_endpoints, "s3", null)
  #   sts     = lookup(var.custom_endpoints, "sts", null)
  # }
}

module "vpc" {
  source = "./vpc"

  cidr_blocks      = var.v4_cidrs
  cluster_id       = var.cluster_id
  region           = var.aws_region
  vpc              = var.aws_vpc
  public_subnets   = var.aws_public_subnets
  private_subnets  = var.aws_private_subnets
  publish_strategy = var.aws_publish_strategy

  availability_zones = sort(
    distinct(
      concat(
        var.aws_controller_availability_zones,
      ),
    )
  )

  public_ipv4_pool     = var.aws_public_ipv4_pool
  tags                 = local.tags
}

module "bootstrap" {
  source = "./bootstrap"

  cluster_id    = var.cluster_id
  instance_type = var.aws_bootstrap_instance_type
  region = var.aws_region

  tags = local.tags

  public_subnet_ids   = module.vpc.public_subnet_ids
  private_subnet_ids  = module.vpc.private_subnet_ids
  cidr_blocks         = var.v4_cidrs

  user_data_cloudinit = var.cloudinit
  vpc_id              = module.vpc.vpc_id
  ami_id              = var.aws_region == var.aws_ami_region ? var.aws_ami : aws_ami_copy.imported[0].id
  public_ipv4_pool    = var.aws_public_ipv4_pool
  publish_strategy    = var.aws_publish_strategy
}

# module "controllers" {
#   source = "./controllers"

#   cluster_id    = var.cluster_id
#   instance_type = var.aws_controller_instance_type

#   tags = local.tags

#   availability_zones               = var.aws_controller_availability_zones
#   az_to_subnet_id                  = module.vpc.az_to_public_subnet_id
#   publish_strategy                 = var.aws_publish_strategy
#   instance_count                   = var.controller_count
#   controller_sg_ids                = concat([module.vpc.controller_sg_id], var.aws_controller_security_groups)
#   root_volume_iops                 = var.aws_controller_root_volume_iops
#   root_volume_size                 = var.aws_controller_root_volume_size
#   root_volume_type                 = var.aws_controller_root_volume_type
#   root_volume_encrypted            = var.aws_controller_root_volume_encrypted
#   root_volume_kms_key_id           = var.aws_controller_root_volume_kms_key_id
#   instance_metadata_authentication = var.aws_controller_instance_metadata_authentication
#   # target_group_arns                = module.vpc.aws_lb_target_group_arns
#   # target_group_arns_length         = module.vpc.aws_lb_target_group_arns_length
#   ec2_ami                          = var.aws_region == var.aws_ami_region ? var.aws_ami : aws_ami_copy.imported[0].id
#   user_data_cloudinit              = var.cloudinit
#   # publish_strategy                 = var.aws_publish_strategy
#   # iam_role_name                    = var.aws_controller_iam_role_name
# }

resource "aws_ami_copy" "imported" {
  count             = var.aws_region != var.aws_ami_region ? 1 : 0
  name              = "${var.cluster_id}-controller"
  description       = local.description
  source_ami_id     = var.aws_ami
  source_ami_region = var.aws_ami_region
  encrypted         = true

  tags = merge(
    {
      "Name"         = "${var.cluster_id}-ami-${var.aws_region}"
      "sourceAMI"    = var.aws_ami
      "sourceRegion" = var.aws_ami_region
    },
    local.tags,
  )
}