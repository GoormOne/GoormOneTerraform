resource "aws_instance" "main" {
  ami           = "ami-0ae2c887094315bed"
  instance_type = "t3.micro"
  subnet_id     = var.public-subnet1-id

  # IAM 인스턴스 프로파일 연결
  iam_instance_profile = "SSM_TO_EC2"


  # 보안 그룹 연결
  vpc_security_group_ids = [var.ssm-ec2-sg-id]

  tags = {
    Name = var.ssm-ec2-name
  }
}