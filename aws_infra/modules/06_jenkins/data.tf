# aws_infra/06_jenkins/data.tf

# VPC 및 Subnet 정보
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket
    key = "network/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "alb" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket
    key = "alb/terraform.tfstate"
    region = var.region
  }
}
