locals {
  tags = merge(
    {
      "aap/cluster/${var.cluster_id}" = "owned"
    },
    var.tags,
  )
  description = "Created By AAP Installer"
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
  identifier = "${var.cluster_id}-controller-db"

  db_subnet_group_name = aws_db_subnet_group.controller.name
  vpc_security_group_ids = var.vpc_security_group_ids
 
  instance_class = var.rds_instance_type

  storage_type = var.storage_type
  allocated_storage = var.allocated_storage
  iops = var.storage_iops
  # storage_encrypted = var.storage_encrypted
 
  allow_major_version_upgrade = false
  auto_minor_version_upgrade = false

  engine = "postgres"
  engine_version = var.rds_engine_version

  multi_az = length(var.availability_zones) > 0
  skip_final_snapshot = var.skip_final_snapshot
  username = var.username
  password = var.password

  tags = merge(
    {
      "Name" = "${var.cluster_id}-db-instance"
    },
    local.tags,
  )

  depends_on = [ aws_db_subnet_group.controller ]
}