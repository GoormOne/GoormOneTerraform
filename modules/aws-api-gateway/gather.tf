data "aws_lb" "alb" {
  name = var.alb-name
}


data "aws_subnet" "private-subnet1" {
  filter {
    name   = "tag:Name"
    values = [var.private-subnet-name1]
  }
}

data "aws_subnet" "private-subnet2" {
  filter {
    name   = "tag:Name"
    values = [var.private-subnet-name2]
  }
}

data "aws_security_group" "vpc-link-sg" {
  filter {
    name   = "tag:Name"
    values = [var.vpc-link-sg-name]
  }
}

data "aws_alb_listener" "alb_listener" {
  load_balancer_arn = data.aws_lb.alb.arn
  port              = 80 # 조회하려는 리스너의 실제 포트 번호
}