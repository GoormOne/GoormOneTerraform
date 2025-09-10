terraform {
  required_providers {
    aws = {
      version = ">= 5.0"
      source  = "hashicorp/aws"

    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.10"
    }
  }
}



provider "aws" {
  #alias = "default"
  region = "ap-northeast-2"
}

