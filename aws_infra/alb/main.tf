# aws_infra/alb/main.tf

# 로드밸런스 생성
resource "aws_lb" "aws08_alb" {
  name = "${var.prefix}-alb"
  internal = false
  load_balancer_type = "application"
  security_groups = [data.aws_security_group.aws08_http_sg.id]
  subnets = data.aws_subnets.aws08_public_subnets.ids
  tags = {
    Name = "${var.prefix}-alb"
  }
}

# WAS 대상그룹 생성
resource "aws_lb_target_group" "aws08_alb_was_group" {
  name     = "${var.prefix}-alb-was-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.aws08_vpc.id
  lifecycle {
    create_before_destroy = true
  }
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}

# Jenkins 대상그룹 생성
resource "aws_lb_target_group" "aws08_alb_jenkins_group" {
  name = "${var.prefix}-alb-jenkins-group"
  port = 80
  protocol = "HTTP"
  vpc_id = data.aws_vpc.aws08_vpc.id
  health_check {
    path = "/login"
    protocol = "HTTP"
    matcher = "200,302"
    interval = 30
    timeout = 5
    healthy_threshold = 5
    unhealthy_threshold = 2
  }
  tags = {
    Name = "${var.prefix}-alb-jenkins-group"
  }
}

# 리스너 설정
resource "aws_lb_listener" "aws08_alb_listener" {
  load_balancer_arn = aws_lb.aws08_alb.arn
  port = 443
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn = var.certificate_arn
  //target_group_arn = aws_lb_target_group.aws08_alb_target_group.arn
  default_action {
    type = "fixed-response"
    fixed_response {
      status_code = 404
      content_type = "text/plain"
      message_body = "Not Found"
    }
  }
}

# WAS 리스너 규칙
resource "aws_lb_listener_rule" "aws08_alb_was_rule" {
  listener_arn = aws_lb_listener.aws08_alb_listener.arn
  priority = 1
  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.aws08_alb_was_group.arn
  }
  condition {
    host_header {
      values = ["${var.prefix}-was.busanit.com"]
    }  
  }
}

# Jenkins 리스너 규칙
resource "aws_lb_listener_rule" "aws08_alb_jenkins_rule" {
  listener_arn = aws_lb_listener.aws08_alb_listener.arn
  priority = 20
  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.aws08_alb_jenkins_group.arn
  }
  condition {
    host_header {
      values = ["${var.prefix}-jenkins.busanit.com"]
    }  
  }
}
