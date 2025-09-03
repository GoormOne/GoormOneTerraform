terraform {
  required_providers {
    aws = {
      version = ">= 2.7.0"
      source  = "hashicorp/aws"

    }
  }
}


provider "aws" {
  #alias = "default"
  region = "us-west-2"
}

provider "aws" {        //waf cloudfront는 버지니아에서만 가능 
  alias  = "Virginia"
  region = "us-east-1"
}