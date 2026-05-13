# terraform.terraform 
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "aws08-terraform-state-bucket"
    key = "network/terraform.tfstate"
    region = "ap-northeast-2"
    dynamodb_table = "aws08-terraform-locks"
    #use_lockfile = true
    encrypt = true
  }
}

provider "aws" {
  region = var.region
}