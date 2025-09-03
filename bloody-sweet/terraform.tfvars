# VPC
VPC-NAME         = "3Tier-VPC"
VPC-CIDR         = "10.10.0.0/16"
IGW-NAME         = "Interet-Gateway"
PUBLIC-CIDR1     = "10.10.0.0/24"
PUBLIC-SUBNET1   = "Public-Subnet1"
PUBLIC-CIDR2     = "10.10.1.0/24"
PUBLIC-SUBNET2   = "Public-Subnet2"
PRIVATE-CIDR1    = "10.10.2.0/23"
PRIVATE-SUBNET1  = "Private-Subnet1"
PRIVATE-CIDR2    = "10.10.4.0/23"
PRIVATE-SUBNET2  = "Private-Subnet2"
EIP-NAME1        = "Elastic-IP1"
EIP-NAME2        = "Elastic-IP2"
NGW-NAME1        = "3Tier-NAT1"
NGW-NAME2        = "3Tier-NAT2"
PUBLIC-RT-NAME1  = "3Tier-Public-Route-table1"
PUBLIC-RT-NAME2  = "3Tier-Public-Route-table2"
PRIVATE-RT-NAME1 = "3Tier-Private-Route-table1"
PRIVATE-RT-NAME2 = "3Tier-Private-Route-table2"

# SECURITY GROUP
WEB-ALB-SG-NAME = "client-web-alb-sg"
WAS-ALB-SG-NAME = "client-was-alb-sg"
WEB-SG-NAME = "client-web-sg"
WAS-SG-NAME ="client-was-sg"
DB-SG-NAME  = "client-db-sg"

# RDS
SG-NAME      = "client-rds-sg"
RDS-USERNAME = "admin"
RDS-PWD      = "12345678"
DB-NAME      = "mydb"
RDS-NAME     = "client-RDS"
# RDS-DNS     = "aws"

# ALB
TG-NAME  = "Web-TG"
WAS-TG-NAME  = "WAS-TG"
WEB-ALB-NAME = "Web-elb"
WAS-ALB-NAME ="was-elb"

# IAM
IAM-ROLE              = "cli-iam-role-for-ec2-SSM_"
IAM-POLICY            = "cli-iam-policy-for-ec2-SSM_"
INSTANCE-PROFILE-NAME = "cli-iam-instance-profile-for-ec2-SSM_"

# AUTOSCALING
AMI-NAME             = "client-New-AMI"
LAUNCH-TEMPLATE-NAME = "client-Web-template"
WAS-LAUNCH-TEMPLATE-NAME = "client-was-template"
WAS-ASG-NAME             = "client-was-Tier-ASG"
ASG-NAME             = "client-Tier-ASG"


# CLOUDFRONT
DOMAIN-NAME = "ggomsuman.shop"
CDN-NAME    = "3-Tier-CDN"

# WAF
WEB-ACL-NAME = "3-Tier-WAF"