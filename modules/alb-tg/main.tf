# Creating ALB for Web Tier
resource "aws_lb" "alb" {
  name               = var.alb-name
  internal           = true
  load_balancer_type = "application"

  # 하드코딩된 ID 대신, 데이터 소스나 다른 리소스의 속성을 참조합니다.
  security_groups = [var.alb-sg-id]
  subnets         = [var.private-subnet1-id,var.private-subnet2-id]

  # 추가 속성
  enable_cross_zone_load_balancing = true
  idle_timeout                     = 60
  desync_mitigation_mode           = "defensive"
  xff_header_processing_mode       = "append"

  tags = {
    Name = var.alb-name
  }
}



# Creating Target Group for Web-Tier 
resource "aws_lb_target_group" "alb-tg" {
  name        = "test"
  port        = 8080
  protocol    = "HTTP"
  target_type = "instance"

  # 하드코딩된 ID 대신, 데이터 소스의 속성을 참조합니다.
  vpc_id      = var.vpc-id

  deregistration_delay = 300
  load_balancing_cross_zone_enabled = "use_load_balancer_configuration"
  load_balancing_algorithm_type = "round_robin"

  health_check {
    enabled             = true
    path                = "/test"
    port                = "traffic-port"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = var.alb-tg-name
  }
  depends_on = [ aws_lb.alb ]
}


# Creating ALB listener with port 80 and attaching it to Web-Tier Target Group
resource "aws_lb_listener" "was-alb-listener" {
  # 하드코딩된 ARN 대신, 위에서 정의한 aws_lb 리소스의 arn 속성을 참조합니다.
  load_balancer_arn = aws_lb.alb.arn

  port     = 80
  protocol = "HTTP"

  default_action {
    type = "forward"

    # 하드코딩된 ARN 대신, 위에서 정의한 aws_lb_target_group 리소스의 arn 속성을 참조합니다.
    target_group_arn = aws_lb_target_group.alb-tg.arn
  }

  tags = {
    Name = var.alb-listener-name
  }

  depends_on = [ aws_lb_target_group.alb-tg]
}