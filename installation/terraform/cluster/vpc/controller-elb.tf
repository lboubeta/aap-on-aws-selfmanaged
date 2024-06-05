resource "aws_lb" "controller_internal" {
  load_balancer_type               = "network"
  subnets                          = data.aws_subnet.private.*.id
  internal                         = true
  enable_cross_zone_load_balancing = true

  tags = merge(
    {
      "Name" = "${var.cluster_id}-int"
    },
    var.tags,
  )

  timeouts {
    create = "20m"
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_lb" "controller_external" {
  count = local.public_endpoints ? 1 : 0

  load_balancer_type               = "network"
  internal                         = false
  enable_cross_zone_load_balancing = true

  dynamic "subnet_mapping" {
    for_each = range(length(data.aws_subnet.public))

    content {
      subnet_id     = data.aws_subnet.public[subnet_mapping.key].id
      allocation_id = aws_eip.controller_nlb_public[subnet_mapping.key].id
    }
  }

  tags = merge(
    {
      "Name" = "${var.cluster_id}-ext"
    },
    var.tags,
  )

  timeouts {
    create = "20m"
  }
}

resource "aws_eip" "controller_nlb_public" {
  count  = length(var.availability_zones)
  domain = "vpc"

  public_ipv4_pool = var.public_ipv4_pool == "" ? null : var.public_ipv4_pool

  tags = merge(
    {
      "Name" = "${var.cluster_id}-eip-${var.availability_zones[count.index]}-lb-web"
    },
    var.tags,
  )

  # Terraform does not declare an explicit dependency towards the internet gateway.
  # this can cause the internet gateway to be deleted/detached before the EIPs.
  # https://github.com/coreos/tectonic-installer/issues/1017#issuecomment-307780549
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_lb_target_group" "controller_internal" {
  protocol = "TCP"
  port     = 443
  vpc_id   = data.aws_vpc.cluster_vpc.id

  target_type = "ip"

  tags = merge(
    {
      "Name" = "${var.cluster_id}-cint"
    },
    var.tags,
  )

  # health_check {
  #   healthy_threshold   = 2
  #   unhealthy_threshold = 2
  #   interval            = 10
  #   port                = 443
  #   protocol            = "HTTPS"
  #   path                = "/readyz"
  # }
}

resource "aws_lb_target_group" "controller_external" {
  count = local.public_endpoints ? 1 : 0

  protocol = "TCP"
  port     = 443
  vpc_id   = data.aws_vpc.cluster_vpc.id

  target_type = "ip"

  tags = merge(
    {
      "Name" = "${var.cluster_id}-cext"
    },
    var.tags,
  )

  # health_check {
  #   healthy_threshold   = 2
  #   unhealthy_threshold = 2
  #   interval            = 10
  #   port                = 443
  #   protocol            = "HTTPS"
  #   path                = "/readyz"
  # }
}


resource "aws_lb_listener" "controller_internal_web" {
  load_balancer_arn = aws_lb.controller_internal.arn
  protocol          = "TCP"
  port              = "443"

  default_action {
    target_group_arn = aws_lb_target_group.controller_internal.arn
    type             = "forward"
  }
}

resource "aws_lb_listener" "controller_external_web" {
  count = local.public_endpoints ? 1 : 0

  load_balancer_arn = aws_lb.controller_external[0].arn
  protocol          = "TCP"
  port              = "443"

  default_action {
    target_group_arn = aws_lb_target_group.controller_external[0].arn
    type             = "forward"
  }
}
