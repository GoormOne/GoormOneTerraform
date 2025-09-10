# =================================================================
# SSM EC2용 보안 그룹 (신규 추가)
# =================================================================
resource "aws_security_group" "ssm_ec2_sg" {
  name        = var.ssm-ec2-sg-name # variables.tf에 이 변수 추가 필요
  description = "Security group for SSM EC2 management instance"
  vpc_id      = var.vpc-id

  # SSM Agent는 아웃바운드 통신만 필요하므로 인바운드 규칙은 필요 없음
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.ssm-ec2-sg-name
  }
}

resource "aws_security_group" "vpc_link_sg" {
  name        = var.vpc-link-sg-name
  description = "Security group for the HTTP API VPC Link"
  vpc_id      = var.vpc-id# 기존 Target Group에서 사용한 VPC 데이터 소스 참조

  # 이 보안 그룹에서 나가는(Egress) 트래픽은 모두 허용합니다.
  # ALB로 요청을 보내야 하기 때문입니다.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.vpc-link-sg-name
  }
  depends_on = [aws_security_group.ssm_ec2_sg]
}



# =================================================================
# Internal ALB Security Group
# =================================================================
resource "aws_security_group" "internal_alb_sg" {
  name        = var.alb-sg-name
  description = "Security group for Internal ALB"
  vpc_id      = var.vpc-id

  ingress {
    description     = "Allow HTTP from VPC Endpoint"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks = [var.vpc-cidr]
  }
  ingress {
    description     = "Allow ALL traffic from SSM EC2" # 설명도 명확하게 수정
    from_port       = 0
    to_port         = 0
    protocol        = "-1" # "-1"은 모든 프로토콜을 의미
    security_groups = [aws_security_group.ssm_ec2_sg.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.alb-sg-name
  }
  depends_on = [aws_security_group.vpc_link_sg]
}

resource "aws_security_group_rule" "allow_vpclink_to_alb" {
  type                     = "ingress"
  from_port                = 80 # ALB 리스너 포트 (aws_lb_listener.was-alb-listener.port 참조)
  to_port                  = 80 # ALB 리스너 포트
  protocol                 = "tcp"

  # 소스(Source)를 위에서 만든 VPC Link 보안 그룹으로 지정합니다.
  source_security_group_id = aws_security_group.vpc_link_sg.id

  # 규칙을 추가할 대상은 기존 ALB의 보안 그룹입니다.
  security_group_id        = aws_security_group.internal_alb_sg.id

  depends_on = [aws_security_group.internal_alb_sg]
}


# =================================================================
# EKS Cluster Security Group
# =================================================================
resource "aws_security_group" "eks_cluster_sg" {
  name        = var.eks-cluster-sg-name
  description = "Security group for EKS Cluster"
  vpc_id      = var.vpc-id

  ingress {
    description     = "Allow ALL traffic from SSM EC2" # 설명도 명확하게 수정
    from_port       = 0
    to_port         = 0
    protocol        = "-1" # "-1"은 모든 프로토콜을 의미
    security_groups = [aws_security_group.ssm_ec2_sg.id]
  }
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  

  tags = {
    Name = var.eks-cluster-sg-name
  }
  depends_on = [aws_security_group.internal_alb_sg]
}

# =================================================================
# EKS Node Group Security Group
# =================================================================
resource "aws_security_group" "eks_node_sg" {
  name        = var.eks-node-sg-name
  description = "Security group for EKS Node Group"
  vpc_id      = var.vpc-id


  ingress {
    description = "Allow all traffic between nodes"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }
  ingress {
    description     = "Allow ALL traffic from SSM EC2" # 설명도 명확하게 수정
    from_port       = 0
    to_port         = 0
    protocol        = "-1" # "-1"은 모든 프로토콜을 의미
    security_groups = [aws_security_group.ssm_ec2_sg.id]
  }


  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.eks-node-sg-name
  }

  depends_on = [aws_security_group.eks_cluster_sg]
}
# 규칙 1: Node -> Cluster 통신
resource "aws_security_group_rule" "node_to_cluster_https" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_node_sg.id
  security_group_id        = aws_security_group.eks_cluster_sg.id

  depends_on = [aws_security_group.eks_node_sg]
}

# 규칙 2: Cluster -> Node 통신
resource "aws_security_group_rule" "cluster_to_node_all" {
  type                     = "ingress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_cluster_sg.id
  security_group_id        = aws_security_group.eks_node_sg.id

  depends_on = [aws_security_group.eks_node_sg]
}

# =================================================================
# Redis Security Group
# =================================================================
resource "aws_security_group" "redis_sg" {
  name        = var.redis-ec2-sg-name
  description = "Security group for Redis EC2 instance"
  vpc_id      = var.vpc-id

  ingress {
    description     = "Allow Redis access from EKS Node Group"
    from_port       = 6379 # Redis 기본 포트
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_node_sg.id]
  }
  ingress {
    description     = "Allow ALL traffic from SSM EC2" # 설명도 명확하게 수정
    from_port       = 0
    to_port         = 0
    protocol        = "-1" # "-1"은 모든 프로토콜을 의미
    security_groups = [aws_security_group.ssm_ec2_sg.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.redis-ec2-sg-name
  }
  depends_on = [aws_security_group.eks_node_sg]
}

# =================================================================
# PostgreSQL DB Security Group
# =================================================================
resource "aws_security_group" "postgre_db_sg" {
  name        = var.postgre-db-sg-name
  description = "Security group for PostgreSQL DB"
  vpc_id      = var.vpc-id

  ingress {
    description     = "Allow PostgreSQL access from EKS Node Group"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_node_sg.id]
  }
  ingress {
    description     = "Allow ALL traffic from SSM EC2" # 설명도 명확하게 수정
    from_port       = 0
    to_port         = 0
    protocol        = "-1" # "-1"은 모든 프로토콜을 의미
    security_groups = [aws_security_group.ssm_ec2_sg.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.postgre-db-sg-name
  }

  depends_on = [aws_security_group.eks_node_sg]
}

# =================================================================
# DocumentDB Security Group
# =================================================================
resource "aws_security_group" "document_db_sg" {
  name        = var.document-db-sg-name
  description = "Security group for DocumentDB"
  vpc_id      = var.vpc-id

  ingress {
    description     = "Allow DocumentDB access from EKS Node Group"
    from_port       = 27017
    to_port         = 27017
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_node_sg.id]
  }
  ingress {
    description     = "Allow ALL traffic from SSM EC2" # 설명도 명확하게 수정
    from_port       = 0
    to_port         = 0
    protocol        = "-1" # "-1"은 모든 프로토콜을 의미
    security_groups = [aws_security_group.ssm_ec2_sg.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.document-db-sg-name
  }

  depends_on = [aws_security_group.eks_node_sg]
}


output "ssm_ec2_sg_id" {
   value       = aws_security_group.ssm_ec2_sg.id
}

output "vpc_link_sg_id" {
  value       = aws_security_group.vpc_link_sg.id
}
output "alb_sg_id" {
  value       = aws_security_group.internal_alb_sg.id
}

output "eks_cluster_sg_id" {
  value       = aws_security_group.eks_cluster_sg.id
}

output "eks_node_group_id" {
  value       = aws_security_group.eks_node_sg.id
}
output "redis_sg_id" {
  value       = aws_security_group.redis_sg.id
}
output "postgre_db_sg_id" {
  value       = aws_security_group.postgre_db_sg.id
}