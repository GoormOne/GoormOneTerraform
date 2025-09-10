resource "aws_instance" "main" {
  ami           = "ami-0ae2c887094315bed"
  instance_type = "t3.micro"
  subnet_id     = var.private-subnet1-id
  private_ip    = "192.168.3.191"

  # IAM 인스턴스 프로파일 연결
  iam_instance_profile = "SSM_TO_EC2"

  user_data = <<-EOT
              #!/bin/bash

              sudo dnf install -y gcc make
              sudo wget https://download.redis.io/releases/redis-7.2.4.tar.gz
              sudo tar xzf redis-7.2.4.tar.gz
              sudo make
              sudo make install
              EOT

  vpc_security_group_ids = [var.redis-ec2-sg-id]

  tags = {
    Name = var.redis-ec2-name
  }
}