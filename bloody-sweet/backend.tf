terraform {
  required_providers {
    aws = {
      version = ">= 5.0"
      source  = "hashicorp/aws"

    }
  }
}


provider "aws" {
  #alias = "default"
  region = "ap-northeast-2"
}

