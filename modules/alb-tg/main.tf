# Creating ALB for Web Tier
resource "aws_lb" "web-elb" {
  name = var.web-alb-name
  internal           = false
  load_balancer_type = "application"
  subnets            = [data.aws_subnet.public-subnet1.id, data.aws_subnet.public-subnet2.id]
  security_groups    = [data.aws_security_group.web-alb-sg.id]
  ip_address_type    = "ipv4"
  enable_deletion_protection = false
  tags = {
    Name = var.web-alb-name
  }
}
output "web_alb_dns" {
  value = aws_lb.web-elb.dns_name
}


# Creating Target Group for Web-Tier 
resource "aws_lb_target_group" "web-tg" {
  
  name = var.tg-name
  health_check {
    enabled = true
    interval            = 10
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }##상태 검사 
  target_type = "instance"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.vpc.id

  tags = {
    Name = var.tg-name
  }

  lifecycle {
    prevent_destroy = false
  } 
  depends_on = [ aws_lb.web-elb ]
}

#---------------------------------------
# Creating ALB listener with port 80 and attaching it to Web-Tier Target Group
resource "aws_lb_listener" "web-alb-listener" {
  load_balancer_arn = aws_lb.web-elb.arn
  
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web-tg.arn
  }

  depends_on = [ aws_lb.web-elb ]
}

resource "aws_lb_listener" "web-alb-listener_https" {
  load_balancer_arn = aws_lb.web-elb.arn
  
  port              = 443
  protocol          = "HTTPS"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web-tg.arn
  } 
   certificate_arn = "arn:aws:acm:us-west-2:891377163278:certificate/9a65a828-d4ec-4f79-9e15-e464d5202e47"  # Replace with your actual certificate ARN

  depends_on = [ aws_lb.web-elb ]
}













# Creating ALB for Web Tier
resource "aws_lb" "was-elb" {
  name = var.was-alb-name
  internal           = true
  load_balancer_type = "application"
  subnets            = [data.aws_subnet.private-subnet1.id, data.aws_subnet.private-subnet2.id]
  security_groups    = [data.aws_security_group.was-alb-sg.id]
  ip_address_type    = "ipv4"
  enable_deletion_protection = false
  tags = {
    Name = var.was-alb-name
  }
}

output "was_alb_dns" {
  value = aws_lb.was-elb.dns_name
}


# Creating Target Group for Web-Tier 
resource "aws_lb_target_group" "was-tg" {
  name = var.was-tg-name
  health_check {
    enabled = true
    interval            = 10
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }##상태 검사 
  target_type = "instance"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.vpc.id

  tags = {
    Name = var.was-tg-name
  }

  lifecycle {
    prevent_destroy = false
  } 
  depends_on = [ aws_lb.was-elb ]
}


# Creating ALB listener with port 80 and attaching it to Web-Tier Target Group
resource "aws_lb_listener" "was-alb-listener" {
  load_balancer_arn = aws_lb.was-elb.arn
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.was-tg.arn
  }

  depends_on = [ aws_lb.was-elb ]
}