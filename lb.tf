resource "aws_eip" "lb" {
  vpc = true

  tags = {
    Name = "${var.project_name}-eip"
  }
}

resource "aws_alb" "eip_lb" {
  name               = "${var.project_name}-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [module.vpc_subnet.public_subnet_ids[0]]
  security_groups    = [aws_security_group.mdm_api_sg.id]

  tags = {
    Name = "${var.project_name}-lb"
  }
}

resource "aws_alb_target_group" "eip_target" {
  name_prefix      = "mdm-tg"
  port             = var.container_internal_port
  protocol         = "HTTP"
  vpc_id           = module.vpc_subnet.public_subnet_ids[0]
  target_type      = "ip"
  health_check {
    interval            = 30
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    matcher             = "200"
  }
}

resource "aws_alb_listener" "eip_listener" {
  load_balancer_arn = aws_alb.eip_lb.arn
  port              = var.http_server_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.eip_target.arn
  }
}