# aws_infra/asg/data.tf
data "aws_vpc" "aws08_vpc" {
  filter {
    name = "tag:Name"
    values = ["${var.prefix}-vpc"]
  }
}
data "aws_subnets" "aws08_private_subnets" {
  filter {
    name = "tag:Name"
    values = ["${var.prefix}-private-subnet-*"]
  }
}
data "aws_security_group" "aws08_ssh_sg" {
  filter {
    name = "tag:Name"
    values = ["${var.prefix}-ssh-sg"]
  }
}
data "aws_security_group" "aws08_http_sg" {
  filter {
    name = "tag:Name"
    values = ["${var.prefix}-http-sg"]
  }
}
data "aws_iam_instance_profile" "aws08_ec2_instance_profile" {
  name = "${var.prefix}-ec2-instance-profile" #IAM  EC2 instance참고
} 
data "aws_ami" "aws08_instance_ami" {
  most_recent = true
  owners = ["self"]
  filter {
    name = "tag:Name"
    values = ["${var.prefix}-instance-ami"]
  }
}
data "aws_lb_target_group" "aws08_was_group" {
  name = "${var.prefix}-alb-was-group" # 로드밸런서 WAS 그룹 참고
}