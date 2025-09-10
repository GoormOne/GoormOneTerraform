resource "aws_instance" "main" {
  ami           = "ami-0f6e9a5e5a5a3d9e8"
  instance_type = "t3.micro"
  subnet_id     = var.private-subnet1-id

  # IAM 인스턴스 프로파일 연결
  iam_instance_profile = "SSM_TO_EC2"

  # 보안 그룹 연결
  vpc_security_group_ids = [var.redis-ec2-sg-id]

  tags = {
    Name = var.redis-ec2-name
  }
}