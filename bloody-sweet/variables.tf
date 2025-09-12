# VPC
variable "VPC-NAME" {description = "vpc name"}
variable "VPC-CIDR" {}
variable "IGW-NAME" {}
variable "PUBLIC-CIDR1" {}
variable "PUBLIC-SUBNET1" {}
variable "PUBLIC-CIDR2" {}
variable "PUBLIC-SUBNET2" {}
variable "PRIVATE-CIDR1" {}
variable "PRIVATE-SUBNET1" {}
variable "PRIVATE-CIDR2" {}
variable "PRIVATE-SUBNET2" {}
variable "PRIVATE-CIDR3" {}
variable "PRIVATE-SUBNET3" {}
variable "PRIVATE-CIDR4" {}
variable "PRIVATE-SUBNET4" {}
variable "EIP-NAME1" {}
variable "EIP-NAME2" {}
variable "NGW-NAME1" {}
variable "NGW-NAME2" {}
variable "PUBLIC-RT-NAME1" {}
variable "PUBLIC-RT-NAME2" {}
variable "PRIVATE-RT-NAME1" {}
variable "PRIVATE-RT-NAME2" {}
variable "PRIVATE-RT-NAME3" {}
variable "PRIVATE-RT-NAME4" {}


# SECURITY GROUP
variable "VPC-LINK-SG-NAME" {}
variable "SSM-EC2-SG-NAME" {}
variable "ALB-SG-NAME" {}
variable "REDIS-EC2-SG-NAME" {}
variable "EKS-CLUSTER-SG-NAME" {}
variable "EKS-NODE-SG-NAME" {}
variable "POSTGRE-DB-SG-NAME" {}
variable "DOCUMENT-DB-SG-NAME" {}
variable "MSK-SG-NAME" {}

# RDS
variable "POSTGRE-DB-SANPSHOT-IDENTIFIER" {}
variable "POSTGRE-DB-NAME" {}


# DOCUMENT DB
variable "DOCUMENT-DB-USERNAME" {}
variable "DOCUMENT-DB-PWD" {}
variable "DOCUMENT-DB-NAME" {}


#EC2-SSM
variable "SSM-EC2-NAEM" {}


# ALB
variable "ALB-NAME" {}
variable "ALB-TG-NAME" {}
variable "ALB-LISTENER-NAME" {}


#VPC_LINK
variable "VPC-LINK-NAME" {}

#EC2-REDIS
variable "REDIS-EC2-NAEM" {}

#EKS-CLUSTER
variable "EKS-CLUSTER-NAME" {}

#MSK
variable "MSK-CLUSTER-NAME" {}


# IAM
variable "IAM-ROLE" {}
variable "IAM-POLICY" {}
variable "INSTANCE-PROFILE-NAME" {}

# AUTOSCALING
variable "AMI-NAME" {}
variable "LAUNCH-TEMPLATE-NAME" {}
variable "WAS-LAUNCH-TEMPLATE-NAME" {}
variable "ASG-NAME" {}
variable "WAS-ASG-NAME" {}

# CLOUDFFRONT
variable "DOMAIN-NAME" {}
variable "CDN-NAME" {}

# WAF
variable "WEB-ACL-NAME" {}











# variable "" {}
# variable "" {}
# variable "" {}
# variable "" {}
# variable "" {}
# variable "" {}
# variable "" {}
# variable "" {}
# variable "" {}
# variable "" {}