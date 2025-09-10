# VPC
VPC-NAME         = "Groom-VPC"
VPC-CIDR         = "192.168.0.0/16"
IGW-NAME         = "Groom-Interet-Gateway"
PUBLIC-CIDR1     = "192.168.1.0/24"
PUBLIC-SUBNET1   = "Public-Subnet1"
PUBLIC-CIDR2     = "192.168.2.0/24"
PUBLIC-SUBNET2   = "Public-Subnet2"
PRIVATE-CIDR1    = "192.168.3.0/24"
PRIVATE-SUBNET1  = "Private-Subnet1"
PRIVATE-CIDR2    = "192.168.4.0/24"
PRIVATE-SUBNET2  = "Private-Subnet2"
PRIVATE-CIDR3    = "192.168.5.0/24"
PRIVATE-SUBNET3  = "Private-Subnet3"
PRIVATE-CIDR4    = "192.168.6.0/24"
PRIVATE-SUBNET4  = "Private-Subnet4"
EIP-NAME1        = "Elastic-IP1"
EIP-NAME2        = "Elastic-IP2"
NGW-NAME1        = "Groom-NAT1"
NGW-NAME2        = "Groom-NAT2"
PUBLIC-RT-NAME1  = "Groom-Public-Route-table1"
PUBLIC-RT-NAME2  = "Groom-Public-Route-table2"
PRIVATE-RT-NAME1 = "Groom-Private-Route-table1"
PRIVATE-RT-NAME2 = "Groom-Private-Route-table2"
PRIVATE-RT-NAME3 = "Groom-Private-Route-table3"
PRIVATE-RT-NAME4 = "Groom-Private-Route-table4"

# SECURITY GROUP
VPC-LINK-SG-NAME = "vpc-link-sg"
SSM-EC2-SG-NAME = "ssm-ec2-sg"
ALB-SG-NAME = "alb-sg"
REDIS-EC2-SG-NAME = "redis-ec2-sg"//나중에 생기면 적용
EKS-CLUSTER-SG-NAME = "eks-cluster-sg"//나중에 eks 생기면 적용
EKS-NODE-SG-NAME = "eks-node-sg"
POSTGRE-DB-SG-NAME  = "postgre-db-sg"
DOCUMENT-DB-SG-NAME   = "document-db-sg"


# POSTGRE
POSTGRE-DB-SANPSHOT-IDENTIFIER = "arn:aws:rds:ap-northeast-2:490913547024:snapshot:db-groom"
POSTGRE-DB-NAME = "Groom-Postgre-db"



# DOCUMENTDB
DOCUMENT-DB-USERNAME = "ksm3255"
DOCUMENT-DB-PWD      = "!4786buch"
DOCUMENT-DB-NAME      = "GroomDocument DB"


#EC2-SSM
SSM-EC2-NAEM = "ssm-ec2-name"




# ALB
ALB-NAME ="GroomALb"
ALB-TG-NAME = "GroomAlb-target-group"
ALB-LISTENER-NAME = "GroomALB-listener"

#VPC_LINK
VPC-LINK-NAME = "Groomvpc_link"

#EC2-REDIS
REDIS-EC2-NAEM = "Groom-redis-ec2"



# IAM
IAM-ROLE              = "cli-iam-role-for-ec2-SSM_"
IAM-POLICY            = "cli-iam-policy-for-ec2-SSM_"
INSTANCE-PROFILE-NAME = "cli-iam-instance-profile-for-ec2-SSM_"

# AUTOSCALING
AMI-NAME             = " New-AMI"
LAUNCH-TEMPLATE-NAME = " Web-template"
WAS-LAUNCH-TEMPLATE-NAME = "was-template"
WAS-ASG-NAME             = "was-Tier-ASG"
ASG-NAME             = "Tier-ASG"


# CLOUDFRONT
DOMAIN-NAME = "ggomsuman.shop"
CDN-NAME    = "3-Tier-CDN"

# WAF
WEB-ACL-NAME = "3-Tier-WAF"