data "aws_lb" "alb" {
  name = var.alb-name
}





data "aws_alb_listener" "alb_listener" {
  load_balancer_arn = data.aws_lb.alb.arn
  port              = 80 # 조회하려는 리스너의 실제 포트 번호
}