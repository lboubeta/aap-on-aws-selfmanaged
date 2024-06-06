locals {
  tags = merge(
    {
      "aap/cluster/${var.cluster_id}" = "owned"
    },
    var.tags,
  )
  description = "Created By AAP Installer"
}

resource "aws_security_group" "rds" {
  vpc_id      = var.vpc_id
  description = local.description

  timeouts {
    create = "20m"
  }

  tags = merge(
    {
      "Name" = "${var.cluster_id}-rds-sg"
    },
    var.tags,
  )
}

resource "aws_security_group_rule" "rds_ingress_posgresql" {
  type              = "ingress"
  security_group_id = aws_security_group.rds.id
  description       = local.description

  protocol    = "tcp"
  cidr_blocks = var.cidr_blocks
  from_port   = 5432
  to_port     = 5432
}


resource "aws_db_subnet_group" "controller" {
  name       = "controller"
  subnet_ids = var.private_subnet_ids

  tags = merge(
    {
      "Name" = "${var.cluster_id}-db-subnet-group"
    },
    local.tags,
  )

}

resource "aws_db_instance" "controller" {
  db_name = "controller"
  identifier = "db-${var.cluster_id}-controller"

  db_subnet_group_name = aws_db_subnet_group.controller.name
  vpc_security_group_ids = [ aws_security_group.rds.id ]

  instance_class = var.rds_instance_type

  storage_type = var.rds_instance_volume_type
  allocated_storage = var.rds_instance_volume_size
  iops = var.rds_instance_volume_iops
  storage_encrypted = var.rds_instance_volume_encrypted
 
  allow_major_version_upgrade = false
  auto_minor_version_upgrade = false

  engine = "postgres"
  engine_version = var.rds_engine_version

  multi_az = length(var.availability_zones) > 0
  skip_final_snapshot = var.rds_skip_final_snapshot

  username = var.rds_username
  password = var.rds_password

  tags = merge(
    {
      "Name" = "${var.cluster_id}-db-instance"
    },
    local.tags,
  )

  depends_on = [ aws_db_subnet_group.controller ]
}