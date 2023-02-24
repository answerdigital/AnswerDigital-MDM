
resource "aws_lb_target_group" "mdm_target_group" {
  name        = "mdm-app-front"
  port        = var.container_internal_port
  protocol    = var.http_protocol
  target_type      = "ip" # set target_type to ip
  vpc_id      = module.vpc_subnet.vpc_id

  stickiness {
    enabled     = true
    type        = "lb_cookie"
    cookie_name = "mdm_cookie"
  }

  health_check {
    enabled             = true
    healthy_threshold   = 3
    interval            = 30
    matcher             = 200
    path                = "/"
    port                = "traffic-port"
    protocol            = var.http_protocol
    timeout             = 10
    unhealthy_threshold = 2
  }
}

resource "aws_lb" "mdm_lb" {
  name                      = "mdm-app-lb"
  internal                  = false
  load_balancer_type        = "application"
  security_groups           = [aws_security_group.mdm_api_sg.id]
  subnets                   = [module.vpc_subnet.public_subnet_ids[0], module.vpc_subnet.public_subnet_ids[1]]
  enable_deletion_protection = true
  tags = {
    Name = "mdm-app-lb"
  }
}

# Redirects http traffic to https
resource "aws_lb_listener" "mdm_lb_listener" {
  load_balancer_arn = aws_lb.mdm_lb.arn
  port              = var.http_server_port
  protocol          = var.http_protocol

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
# Handles https traffic and forwards to ecs task
resource "aws_lb_listener" "mdm_lb_listener2" {
  load_balancer_arn = aws_lb.mdm_lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mdm_target_group.arn
  }
}
# handles http traffic and redirects to https
resource "aws_lb_listener" "mdm_lb_listener3" {
  load_balancer_arn = aws_lb.mdm_lb.arn
  port  = var.domain_http_server_port
  protocol = var.http_protocol

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"

    }
  }
}