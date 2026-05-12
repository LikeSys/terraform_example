# aws_infra/alb/data.tf

data "aws_vpc" "aws08_vpc" {
  filter {
    name = "tag:Name"
    values = ["${var.prefix}-vpc"]
  }
}
data "aws_subnets" "aws08_public_subnets" {
  filter {
    name = "tag:Name"
    values = ["${var.prefix}-public-subnet-*"]
  }
}
data "aws_security_group" "aws08_http_sg" {
  filter {
    name = "tag:Name"
    values = ["${var.prefix}-http-sg"]
  }
}