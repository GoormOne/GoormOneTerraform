data "aws_subnet" "public-subnet1" {
  filter {
    name   = "tag:Name"
    values = [var.public-subnet-name1]
  }
}
data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = [var.vpc-name]
  }
}




data "aws_security_group" "ssm-ec2-sg-name" {
  filter {
    name   = "tag:Name"
    values = [var.ssm-ec2-sg-name]
  }
}