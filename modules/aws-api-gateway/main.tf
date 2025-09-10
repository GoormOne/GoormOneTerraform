resource "aws_apigatewayv2_vpc_link" "to_alb" {
  name = var.vpc-link-name

  # target_arns 대신 subnet_ids와 security_group_ids를 사용합니다.
  subnet_ids         = [var.private-subnet1-id,var.private-subnet2-id]
  security_group_ids = [var.vpc-link-sg-id] # 필요시 특정 SG ID로 제한 가능

  tags = {
    Name = var.vpc-link-name
  }
}

# 생성된 VPC Link의 ID를 출력
output "vpc_link_id" {
  description = "The ID of the created VPC Link"
  value       = aws_apigatewayv2_vpc_link.to_alb.id
}



resource "aws_apigatewayv2_api" "my_api" {
  name          = "MyAlbHttpApi"
  protocol_type = "HTTP"
  description   = "GroomApi gate way"
}

# ALB와 직접 연결되는 통합(Integration) 생성
resource "aws_apigatewayv2_integration" "alb_integration" {
  api_id = aws_apigatewayv2_api.my_api.id

  integration_type    = "HTTP_PROXY"
  connection_type     = "VPC_LINK"

  # connection_id에 위에서 만든 VPC Link 리소스의 ID를 연결합니다.
  connection_id       = aws_apigatewayv2_vpc_link.to_alb.id

  # 실제 연결 대상인 ALB 리스너의 ARN을 지정합니다.
  integration_uri     = data.aws_alb_listener.alb_listener.arn

  integration_method = "ANY"
}

# 모든 요청을 ALB 통합으로 보내는 라우트(Route) 생성
resource "aws_apigatewayv2_route" "default_route" {
  api_id    = aws_apigatewayv2_api.my_api.id
  route_key = "$default" # 모든 경로와 메서드를 처리하는 기본 라우트
  target    = "integrations/${aws_apigatewayv2_integration.alb_integration.id}"
}

# API를 배포하고 호출 URL을 생성하는 스테이지(Stage)
resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.my_api.id
  name        = "$default"
  auto_deploy = true # API 변경 시 자동으로 배포
}
