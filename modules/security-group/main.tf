
# =================================================================
# Internal ALB Security Group
# =================================================================
resource "aws_security_group" "internal_alb_sg" {
  name        = var.alb-sg-name
  description = "Security group for Internal ALB"
  vpc_id      = data.aws_vpc.vpc.id

  ingress {
    description     = "Allow HTTP from VPC Endpoint"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
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
}



# =================================================================
# EKS Cluster Security Group
# =================================================================
resource "aws_security_group" "eks_cluster_sg" {
  name        = var.eks-cluster-sg-name
  description = "Security group for EKS Cluster"
  vpc_id      = data.aws_vpc.vpc.id


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
  vpc_id      = data.aws_vpc.vpc.id


  ingress {
    description = "Allow all traffic between nodes"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
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
  vpc_id      = data.aws_vpc.vpc.id

  ingress {
    description     = "Allow Redis access from EKS Node Group"
    from_port       = 6379 # Redis 기본 포트
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_node_sg.id]
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
  vpc_id      = data.aws_vpc.vpc.id

  ingress {
    description     = "Allow PostgreSQL access from EKS Node Group"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_node_sg.id]
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
  vpc_id      = data.aws_vpc.vpc.id

  ingress {
    description     = "Allow DocumentDB access from EKS Node Group"
    from_port       = 27017
    to_port         = 27017
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_node_sg.id]
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