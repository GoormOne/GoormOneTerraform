data "aws_ami" "ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  owners = ["099720109477"] 
}

data "aws_security_group" "web-sg" {
  filter {
    name   = "tag:Name"
    values = [var.web-sg-name]
  }
}

data "aws_security_group" "was-sg" {
  filter {
    name   = "tag:Name"
    values = [var.was-sg-name]
  }
}

data "aws_subnet" "public-subnet1" {
  filter {
    name   = "tag:Name"
    values = [var.public-subnet-name1]
  }
}

data "aws_subnet" "public-subnet2" {
  filter {
    name   = "tag:Name"
    values = [var.public-subnet-name2]
  }
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

data "aws_lb_target_group" "tg" {
  tags = {
    Name = var.tg-name
  }
  
}
data "aws_lb_target_group" "was-tg" {
  tags = {
    Name = var.was-tg-name
  }
}



data "aws_iam_instance_profile" "instance-profile" {
  name = var.instance-profile-name
}




# data "template_file" "user_data" {
#   template = "../modules/aws-autoscaling/deploy.sh"

#   vars = {
#      web_dns    = "${var.web-alb-dns}"
#      was_dns    = "${var.was-alb-dns}."
#    }
   
# }
# data "template_cloudinit_config" "config" {

#   base64_encode = true

#   # Main cloud-config configuration file.
#   part {
#     filename     = "init.cfg"
#     content_type = "text/cloud-config"
#     content      = "${data.template_file.script.rendered}"
#   }

#   part {
#     content_type = "text/x-shellscript"
#     content      = "baz"
#   }

#   part {
#     content_type = "text/x-shellscript"
#     content      = "ffbaz"
#   }
# }

# data "aws_rds_cluster" "aurora_cluster" {
#   cluster_identifier      = "aurora-cluster"
#    tags = {
#      Name=var.rds-dns
#    }
# }








# data "template_cloudinit_config" "user_data" {
#   template = filebase64("../modules/aws-autoscaling/deploy.sh")

#   vars = {
#     web_dns    = "${data.aws_lb.web_elb.dns_name}"
#     was_dns    = "${data.aws_lb.was_elb.dns_name}"

#   }
# }