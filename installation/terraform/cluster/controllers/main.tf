locals {
  // Because of the issue https://github.com/hashicorp/terraform/issues/12570, the consumers cannot use a dynamic list for count
  // and therefore are force to implicitly assume that the list is of aws_lb_target_group_arns_length - 1, in case there is no api_external
  target_group_arns_length = var.publish_strategy == "External" ? var.target_group_arns_length : var.target_group_arns_length - 1
  description              = "Created By AAP Installer"
}

data "aws_partition" "current" {}

data "aws_ebs_default_kms_key" "current" {}

resource "aws_network_interface" "controller" {
  count       = var.instance_count
  description = local.description
  subnet_id   = var.az_to_subnet_id[var.availability_zones[count.index]]

  security_groups = var.controller_sg_ids

  tags = merge(
    {
      "Name" = "${var.cluster_id}-controller-${count.index}"
    },
    var.tags,
  )
}

resource "aws_instance" "controller" {
  count = var.instance_count
  ami   = var.ec2_ami

  instance_type        = var.instance_type
  user_data            = var.user_data_cloudinit

  network_interface {
    network_interface_id = aws_network_interface.controller[count.index].id
    device_index         = 0
  }

  lifecycle {
    # Ignore changes in the AMI which force recreation of the resource. This
    # avoids accidental deletion of nodes whenever a new CoreOS Release comes
    # out.
    ignore_changes = [ami]
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = var.instance_metadata_authentication
  }

  tags = merge(
    {
      "Name" = "${var.cluster_id}-controller-${count.index}"
    },
    var.tags,
  )

  root_block_device {
    volume_type = var.root_volume_type
    volume_size = var.root_volume_size
    iops        = var.root_volume_iops
    # encrypted   = var.root_volume_encrypted
    # kms_key_id  = var.root_volume_kms_key_id == "" ? data.aws_ebs_default_kms_key.current.key_arn : var.root_volume_kms_key_id
  }

  volume_tags = merge(
    {
      "Name" = "${var.cluster_id}-controller-${count.index}-vol"
    },
    var.tags,
  )

  depends_on = [
    aws_network_interface.controller
  ]
}

resource "aws_lb_target_group_attachment" "controllers" {
  count = var.instance_count * local.target_group_arns_length

  target_group_arn = var.target_group_arns[count.index % local.target_group_arns_length]
  target_id        = aws_instance.controller[floor(count.index / local.target_group_arns_length)].private_ip
}