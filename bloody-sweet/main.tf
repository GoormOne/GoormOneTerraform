module "vpc" {
  source = "../modules/aws-vpc"
  vpc-name        = var.VPC-NAME
  vpc-cidr        = var.VPC-CIDR
  igw-name        = var.IGW-NAME
  public-cidr1    = var.PUBLIC-CIDR1
  public-subnet1  = var.PUBLIC-SUBNET1
  public-cidr2    = var.PUBLIC-CIDR2
  public-subnet2  = var.PUBLIC-SUBNET2
  private-cidr1   = var.PRIVATE-CIDR1
  private-subnet1 = var.PRIVATE-SUBNET1
  private-cidr2   = var.PRIVATE-CIDR2
  private-subnet2 = var.PRIVATE-SUBNET2
  private-cidr3   = var.PRIVATE-CIDR3
  private-subnet3 = var.PRIVATE-SUBNET3
  private-cidr4   = var.PRIVATE-CIDR4
  private-subnet4 = var.PRIVATE-SUBNET4
  eip-name1       = var.EIP-NAME1
  eip-name2       = var.EIP-NAME2

  ngw-name1        = var.NGW-NAME1
  ngw-name2        = var.NGW-NAME2
  public-rt-name1  = var.PUBLIC-RT-NAME1
  public-rt-name2  = var.PUBLIC-RT-NAME2
  private-rt-name1 = var.PRIVATE-RT-NAME1
  private-rt-name2 = var.PRIVATE-RT-NAME2
  private-rt-name3 = var.PRIVATE-RT-NAME3
  private-rt-name4 = var.PRIVATE-RT-NAME4
}

module "security-group" {
  source = "../modules/security-group"

  vpc-link-sg-name = var.VPC-LINK-SG-NAME
  vpc-name    = var.VPC-NAME
  ssm-ec2-sg-name = var.SSM-EC2-SG-NAME
  alb-sg-name = var.ALB-SG-NAME
  redis-ec2-sg-name = var.REDIS-EC2-SG-NAME
  eks-cluster-sg-name = var.EKS-CLUSTER-SG-NAME
  eks-node-sg-name = var.EKS-NODE-SG-NAME
  postgre-db-sg-name = var.POSTGRE-DB-SG-NAME
  document-db-sg-name  = var.DOCUMENT-DB-SG-NAME


  depends_on = [module.vpc]
}

module "rds" {
  source = "../modules/aws-rds"

  postgre-db-sg-name           = var.POSTGRE-DB-SG-NAME
  private-subnet-name3 = var.PRIVATE-SUBNET3
  private-subnet-name4 = var.PRIVATE-SUBNET4
  postgre-db-snapshot-identifier = var.POSTGRE-DB-SANPSHOT-IDENTIFIER
  postgre-db-name = var.DOCUMENT-DB-NAME


  depends_on = [module.security-group]
}

module "documentdb" {
  source = "../modules/aws-documentdb"

  private-subnet-name3 = var.PRIVATE-SUBNET3
  private-subnet-name4 = var.PRIVATE-SUBNET4
  document-db-sg-name  = var.DOCUMENT-DB-SG-NAME
  document-db-username = var.DOCUMENT-DB-USERNAME
  document-db-pwd      = var.DOCUMENT-DB-PWD
  document-db-name     = var.DOCUMENT-DB-NAME

  depends_on = [module.security-group]
}

module "ec2_ssm" {
  source = "../modules/aws-ec2"

  ssm-ec2-name = var.SSM-EC2-NAEM
  vpc-name    = var.VPC-NAME
  public-subnet-name1=var.PUBLIC-SUBNET1
  vpc-id = module.vpc.vpc_id
  ssm-ec2-sg-name = var.SSM-EC2-SG-NAME



  depends_on = [module.security-group]
}



#
module "alb" {
  source = "../modules/alb-tg"

  alb-name = var.ALB-NAME
  alb-sg-name = var.ALB-SG-NAME
  private-subnet-name1 = var.PRIVATE-SUBNET1
  private-subnet-name2 = var.PRIVATE-SUBNET2
  vpc-name            = var.VPC-NAME
  alb-tg-name = var.ALB-TG-NAME
  alb-listener-name = var.ALB-LISTENER-NAME


  depends_on = [module.rds]//나중에 module.rds 로 바꾸기
}

module "api-gate-way" {
  source = "../modules/aws-api-gateway"
  vpc-link-name = var.VPC-LINK-NAME
  alb-name = var.ALB-NAME
  private-subnet-name1 = var.PRIVATE-SUBNET1
  private-subnet-name2 = var.PRIVATE-SUBNET2
  vpc-link-sg-name = var.VPC-LINK-SG-NAME

  depends_on = [module.alb]
}


#
# module "iam" {
#   source = "../modules/aws-iam"
#
#   iam-role              = var.IAM-ROLE
#   iam-policy            = var.IAM-POLICY
#   instance-profile-name = var.INSTANCE-PROFILE-NAME
#
#   depends_on = [module.alb]
# }


#
# module "autoscaling" {
#   source = "../modules/aws-autoscaling"
#
#   ami_name              = var.AMI-NAME
#   launch-template-name  = var.LAUNCH-TEMPLATE-NAME
#   was-launch-template-name  = var.WAS-LAUNCH-TEMPLATE-NAME
#   instance-profile-name = var.INSTANCE-PROFILE-NAME
#   web-sg-name           = var.WEB-SG-NAME
#   was-sg-name           = var.WAS-SG-NAME
#   was-tg-name           = var.WAS-TG-NAME
#   tg-name               = var.TG-NAME
#   iam-role              = var.IAM-ROLE
#   public-subnet-name1   = var.PUBLIC-SUBNET1
#   public-subnet-name2   = var.PUBLIC-SUBNET2
#   private-subnet-name1 = var.PRIVATE-SUBNET1
#   private-subnet-name2 = var.PRIVATE-SUBNET2
#   asg-name              = var.ASG-NAME
#   was-asg-name              = var.WAS-ASG-NAME
#   # rds-dns                =    var.RDS-NAME
#   web-alb-dns          =     module.alb.web_alb_dns
#   was-alb-dns          =      module.alb.was_alb_dns
#   rds-dns =                  module.rds.rds_dns
#   depends_on = [module.iam]
# }

# module "route53" {
#   source = "../modules/aws-waf-cdn-acm-route53"

#   domain-name  = var.DOMAIN-NAME
#   cdn-name     = var.CDN-NAME
#   alb-name     = var.ALB-NAME
#   web_acl_name = var.WEB-ACL-NAME

#   depends_on = [ module.autoscaling ]
# }