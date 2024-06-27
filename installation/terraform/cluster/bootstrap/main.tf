locals {
  tags = merge(
    {
      "aap/cluster/${var.cluster_id}" = "owned"
    },
    var.tags,
  )
  description = "Created By AAP Installer"

  public_endpoints = var.publish_strategy == "External" ? true : false
  volume_type      = "gp2"
  volume_size      = 30
  volume_iops      = local.volume_type == "io1" ? 100 : 0

  // s3 object supports only 10 tags. The first 8 tags from
  // the list of tags are used for s3 object
  // slice function uses new_tag_len as excluding index
  new_tag_len    = 8
  sliced_tag_map = length(var.tags) <= local.new_tag_len ? var.tags : { for k in slice(keys(var.tags), 0, local.new_tag_len) : k => var.tags[k] }
  s3_object_tags = merge(
    {
      "aap/cluster/${var.cluster_id}" = "owned"
    },
    local.sliced_tag_map,
  )
}

data "aws_partition" "current" {}

data "aws_ebs_default_kms_key" "current" {}

# resource "aws_s3_bucket" "ignition" {
#   count         = var.aws_preserve_bootstrap_ignition ? 0 : 1
#   bucket        = var.aws_ignition_bucket
#   force_destroy = true

#   tags = merge(
#     {
#       "Name" = "${var.cluster_id}-bootstrap"
#     },
#     local.tags,
#   )

#   lifecycle {
#     ignore_changes = all
#   }
# }

# resource "aws_s3_object" "ignition" {
#   count  = var.aws_preserve_bootstrap_ignition ? 0 : 1
#   bucket = aws_s3_bucket.ignition[0].id
#   key    = "bootstrap.ign"
#   source = var.ignition_bootstrap_file

#   server_side_encryption = "AES256"

#   tags = merge(
#     {
#       "Name" = "${var.cluster_id}-bootstrap"
#     },
#     local.s3_object_tags,
#   )

#   lifecycle {
#     ignore_changes = all
#   }
# }


# resource "aws_iam_instance_profile" "bootstrap" {
#   name = "${var.cluster_id}-bootstrap-profile"

#   role = var.aws_controller_iam_role_name != "" ? var.aws_controller_iam_role_name : aws_iam_role.bootstrap[0].name

#   tags = merge(
#     {
#       "Name" = "${var.cluster_id}-bootstrap-profile"
#     },
#     local.tags,
#   )
# }

# resource "aws_iam_role" "bootstrap" {
#   count = var.aws_controller_iam_role_name == "" ? 1 : 0

#   name = "${var.cluster_id}-bootstrap-role"
#   path = "/"

#   assume_role_policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Action": "sts:AssumeRole",
#             "Principal": {
#                 "Service": "ec2.${data.aws_partition.current.dns_suffix}"
#             },
#             "Effect": "Allow",
#             "Sid": ""
#         }
#     ]
# }
# EOF

#   tags = merge(
#     {
#       "Name" = "${var.cluster_id}-bootstrap-role"
#     },
#     local.tags,
#   )
# }

# resource "aws_iam_role_policy" "bootstrap" {
#   count = var.aws_controller_iam_role_name == "" ? 1 : 0
#   name = "${var.cluster_id}-bootstrap-policy"
#   role = aws_iam_role.bootstrap[0].id

#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Action": "ec2:Describe*",
#       "Resource": "*"
#     },
#     {
#       "Effect": "Allow",
#       "Action": "ec2:AttachVolume",
#       "Resource": "*"
#     },
#     {
#       "Effect": "Allow",
#       "Action": "ec2:DetachVolume",
#       "Resource": "*"
#     }
#   ]
# }
# EOF
# }

resource "aws_instance" "bootstrap" {
  ami = var.ami_id

  # iam_instance_profile        = aws_iam_instance_profile.bootstrap.name
  instance_type               = var.instance_type
  subnet_id                   = var.publish_strategy == "External" ? var.public_subnet_ids[0] : var.private_subnet_ids[0]
  user_data                   = var.user_data_cloudinit
  vpc_security_group_ids      = [ aws_security_group.bootstrap.id ]
  associate_public_ip_address = local.public_endpoints && var.public_ipv4_pool == ""

  lifecycle {
    # Ignore changes in the AMI which force recreation of the resource. This
    # avoids accidental deletion of nodes whenever a new OS release comes out.
    ignore_changes = [ami]
  }

  tags = merge(
    {
      "Name" = "${var.cluster_id}-bootstrap"
    },
    local.tags,
  )

  metadata_options {
    http_endpoint = "enabled"
    # http_tokens   = var.aws_bootstrap_instance_metadata_authentication
  }

  root_block_device {
    volume_type = local.volume_type
    volume_size = local.volume_size
    iops        = local.volume_iops
    # encrypted   = true
    # kms_key_id  = var.root_volume_kms_key_id == "" ? data.aws_ebs_default_kms_key.current.key_arn : var.root_volume_kms_key_id
  }

  volume_tags = merge(
    {
      "Name" = "${var.cluster_id}-bootstrap-vol"
    },
    local.tags,
  )

  connection {
    type = "ssh"
    user = var.cloud_user
    host = self.public_ip
    private_key = var.ssh_private_key
  }

  provisioner "file" {
    content = var.ssh_private_key
    destination = "/home/${var.cloud_user}/.ssh/id_rsa"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod 0600 /home/${var.cloud_user}/.ssh/id_rsa",
    ]
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/config.j2", { 
      aap_controller_hosts = var.controllers
      # aap_ee_hosts = module.execution_vm[*].vm_private_ip
      # aap_hub_hosts = module.hub_vm[*].vm_private_ip
      # aap_eda_hosts = module.eda_vm[*].vm_private_ip
      aap_ee_hosts = []
      aap_hub_hosts = []
      aap_eda_hosts = []

      cloud_user = var.cloud_user
    })

    destination = "/home/${var.cloud_user}/.ssh/config"
  }

  provisioner "remote-exec" {
      inline = [
        "chmod 0644 /home/${var.cloud_user}/.ssh/config",
      ]
  }

  # provisioner "file" {
  #   content = templatefile("${path.module}/templates/inventory.j2", { 
  #     aap_controller_hosts = var.controllers
  #     # aap_ee_hosts = module.execution_vm[*].vm_private_ip
  #     # aap_hub_hosts = module.hub_vm[*].vm_private_ip
  #     # aap_eda_hosts = module.eda_vm[*].vm_private_ip
  #     # aap_eda_allowed_hostnames = module.eda_vm[*].vm_public_ip

  #     aap_db_host = module.rds.rds_hostname
  #     aap_db_port = 5432
  #     aap_db_username = var.aap_db_username
  #     aap_db_password = var.aap_db_password

  #     aap_redhat_username = var.aap_redhat_username
  #     aap_redhat_password= var.aap_redhat_password

  #     aap_admin_password = var.aap_admin_password
  #     aap_admin_username = var.infrastructure_admin_username
  #   })

  #   destination = var.infrastructure_aap_installer_inventory_path
  # }

  # depends_on = [
  #   aws_s3_object.ignition,
  #   # https://bugzilla.redhat.com/show_bug.cgi?id=1859153
  #   aws_iam_instance_profile.bootstrap,
  # ]
}

# resource "aws_lb_target_group_attachment" "bootstrap" {
#   // Because of the issue https://github.com/hashicorp/terraform/issues/12570, the consumers cannot use a dynamic list for count
#   // and therefore are force to implicitly assume that the list is of lb_target_group_arns_length - 1, in case there is no api_external
#   count = local.public_endpoints ? var.lb_target_group_arns_length : var.lb_target_group_arns_length - 1

#   target_group_arn = var.lb_target_group_arns[count.index]
#   target_id        = aws_instance.bootstrap.private_ip
# }

resource "aws_security_group" "bootstrap" {
  vpc_id      = var.vpc_id
  description = local.description

  timeouts {
    create = "20m"
  }

  tags = merge(
    {
      "Name" = "${var.cluster_id}-bootstrap-sg"
    },
    local.tags,
  )
}

resource "aws_security_group_rule" "inbound-ssh" {
  type              = "ingress"
  security_group_id = aws_security_group.bootstrap.id
  description       = local.description

  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 22
  to_port     = 22
}

resource "aws_security_group_rule" "outbound-ssh" {
  type              = "egress"
  security_group_id = aws_security_group.bootstrap.id
  description       = local.description

  protocol    = "tcp"
  cidr_blocks = var.cidr_blocks
  from_port   = 22
  to_port     = 22
}

# Access subscription manager and update packages
resource "aws_security_group_rule" "outbound-https" {
  type              = "egress"
  security_group_id = aws_security_group.bootstrap.id
  description       = local.description

  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 443
  to_port     = 443
}

# Access RDS
resource "aws_security_group_rule" "outbound-postgresql" {
  type              = "egress"
  security_group_id = aws_security_group.bootstrap.id
  description       = local.description

  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 5432
  to_port     = 5432
}


resource "aws_eip" "bootstrap" {
  count            = var.public_ipv4_pool == "" ? 0 : 1
  domain           = "vpc"
  instance         = aws_instance.bootstrap.id
  public_ipv4_pool = var.public_ipv4_pool

  tags = merge(
    {
      "Name" = "${var.cluster_id}-bootstrap-eip"
    },
    local.tags,
  )

  depends_on = [aws_instance.bootstrap]
}