# aws_infra/asg/main.tf

# 시작 템플릿
resource "aws_launch_template" "aws08_launch_template" {
  name_prefix = "${var.prefix}-launch-template-"
  image_id = data.aws_ami.aws08_instance_ami.id
  instance_type = "t3.micro"
  key_name = var.key_name

  iam_instance_profile {
    name = data.aws_iam_instance_profile.aws08_ec2_instance_profile.name
  }
  network_interfaces {
    associate_public_ip_address = "false"
    security_groups = [
      data.aws_security_group.aws08_ssh_sg.id,
      data.aws_security_group.aws08_http_sg.id
    ]
    subnet_id = element(data.aws_subnets.aws08_private_subnets.ids, count.index)
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.prefix}-instance"
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

# 오토스케일링 그룹
resource "aws_autoscaling_group" "aws08_asg" {
  name = "${var.prefix}-asg"
  max_size = ""
  min_size = ""
  desired_capacity = ""
}

# 대상그룹 연결
