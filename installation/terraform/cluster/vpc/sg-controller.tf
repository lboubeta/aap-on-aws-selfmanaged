resource "aws_security_group" "controller" {
  vpc_id      = data.aws_vpc.cluster_vpc.id
  description = local.description

  timeouts {
    create = "20m"
  }

  tags = merge(
    {
      "Name" = "${var.cluster_id}-controller-sg"
    },
    var.tags,
  )
}

resource "aws_security_group_rule" "controller_ingress_ssh" {
  type              = "ingress"
  security_group_id = aws_security_group.controller.id
  description       = local.description

  protocol    = "tcp"
  cidr_blocks = var.cidr_blocks
  from_port   = 22
  to_port     = 22
}

resource "aws_security_group_rule" "controller_egress_ssh" {
  type              = "egress"
  security_group_id = aws_security_group.controller.id
  description       = local.description

  protocol    = "tcp"
  cidr_blocks = var.cidr_blocks
  from_port   = 22
  to_port     = 22
}

resource "aws_security_group_rule" "controller_ingress_http" {
  type              = "ingress"
  security_group_id = aws_security_group.controller.id
  description       = local.description

  protocol    = "tcp"
  cidr_blocks = var.cidr_blocks
  from_port   = 80
  to_port     = 80
}

resource "aws_security_group_rule" "controller_ingress_https" {
  type              = "ingress"
  security_group_id = aws_security_group.controller.id
  description       = local.description

  protocol    = "tcp"
  cidr_blocks = var.cidr_blocks
  from_port   = 443
  to_port     = 443
}

# Temporal: remove when using RDS
resource "aws_security_group_rule" "controller_ingress_posgresql" {
  type              = "ingress"
  security_group_id = aws_security_group.controller.id
  description       = local.description

  protocol    = "tcp"
  cidr_blocks = var.cidr_blocks
  from_port   = 5432
  to_port     = 5432
}

resource "aws_security_group_rule" "controller_egress_posgresql" {
  type              = "egress"
  security_group_id = aws_security_group.controller.id
  description       = local.description

  protocol    = "tcp"
  cidr_blocks = var.cidr_blocks
  from_port   = 5432
  to_port     = 5432
}

resource "aws_security_group_rule" "controller_ingress_receptor" {
  type              = "ingress"
  security_group_id = aws_security_group.controller.id
  description       = local.description

  protocol    = "tcp"
  cidr_blocks = var.cidr_blocks
  from_port   = 27199
  to_port     = 27199
}

resource "aws_security_group_rule" "controller_egress_receptor" {
  type              = "egress"
  security_group_id = aws_security_group.controller.id
  description       = local.description

  protocol    = "tcp"
  cidr_blocks = var.cidr_blocks
  from_port   = 27199
  to_port     = 27199
}
