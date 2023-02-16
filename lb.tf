resource "aws_eip" "lb" {
  vpc = true

  tags = {
    Name = "${var.project_name}-eip"
  }
}

resource "aws_lb" "eip_lb" {
  name               = "${var.project_name}-lb"
  load_balancer_type = "network"
  internal           = false
  ip_address_type    = "ipv4"

  subnet_mapping {
    subnet_id     = module.vpc_subnet.public_subnet_ids[0]
    allocation_id = aws_eip.lb.id
  }

  tags = {
    Name = "${var.project_name}-lb"
  }
}

resource "aws_lb_target_group" "eip_target" {
  name        = "tf-example-lb-tg"
  port        = var.http_server_port
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = module.vpc_subnet.vpc_id

  tags = {
    Name = "${var.project_name}-lb-target-group"
  }
}

resource "aws_lb_listener" "eip_listener" {
  load_balancer_arn = aws_lb.eip_lb.arn
  port              = var.http_server_port
  protocol          = "TCP"


  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.eip_target.arn
  }

  tags = {
    Name = "${var.project_name}-lb-listener"
  }
}