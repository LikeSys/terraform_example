# aws_infra/asg/data.tf

# 1. 태그로 AMI 찾기
data "aws_ami" "was_ami" {
  most_recent = true
  owners      = ["self"] # 내가 만든 AMI 중에서 찾음

  filter {
    name   = "tag:Name"
    values = ["${var.prefix}-instance-ami"]
  }
}

# 2. VPC 및 Subnet 정보
data "aws_vpc" "aws08_vpc" {
  filter {
    name = "tag:Name"
    values = ["${var.prefix}-vpc"]
  }
}

data "aws_subnets" "aws08_private_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.aws08_vpc.id]
  }
  filter {
    name = "tag:Name"
    values = ["${var.prefix}-private-*"]
  }
}

data "aws_security_group" "aws08_was_sg" {
  filter {
    name   = "tag:Name"
    values = ["${var.prefix}-http-sg"]
  }
}

data "aws_iam_instance_profile" "aws08_ec2_profile" {
  name = "${var.prefix}-ec2-instance-profile" #IAM  EC2 instance참고
}

data "aws_lb_target_group" "aws08_was_tg" {
  name = "${var.prefix}-alb-was-group" # 로드밸런서 WAS 그룹 참고
}