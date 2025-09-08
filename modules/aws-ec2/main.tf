resource "aws_instance" "main" {
  ami           = "ami-0ae2c887094315bed"
  instance_type = "t3.micro"
  subnet_id     = data.aws_subnet.public-subnet1.id

  # IAM 인스턴스 프로파일 연결
  iam_instance_profile = "SSM_TO_EC2"

  # 보안 그룹 연결
  vpc_security_group_ids = [data.aws_security_group.ssm-ec2-sg-name.id]

  tags = {
    Name = var.ssm-ec2-name
  }
}