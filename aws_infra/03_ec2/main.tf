# aws_infra/ec2/main.tf

# 1. 원본 instance 생성
resource "aws_instance" "aws08_instance" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  associate_public_ip_address = true
  key_name                    = var.key_name
  subnet_id                   = data.aws_subnet.aws08_public_subnet.id
  security_groups = [
    data.aws_security_group.aws08_ssh_sg.id,
    data.aws_security_group.aws08_http_sg.id
  ]
  # CodeDeploy Agent, Docker 설치 
  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y ruby wget
              sudo apt install -y --reinstall ca-certificates
              sudo update-ca-certificates --fresh
              cd /home/ubuntu
              wget https://aws-codedeploy-ap-northeast-2.s3.amazonaws.com/latest/install
              chmod +x ./install
              ./install auto
              sudo systemctl enable codedeploy-agent
              sudo systemctl start codedeploy-agent

              ${file("${path.module}/user_data/docker-install.sh")}
            EOF

  tags = {
    Name = "${var.prefix}-instance"
  }
}

# 2. Code Deploy Agent, Docker 설치하는 동안 대기
resource "null_resource" "aws08_delay" {
  provisioner "local-exec" {
    command = "sleep 200"
  }
  depends_on = [aws_instance.aws08_instance]
}

# 3. 원본 instance를 이용해 AMI 생성
resource "aws_ami_from_instance" "aws08_ami" {
  name = "${var.prefix}-instance-ami"
  source_instance_id = aws_instance.aws08_instance.id
  snapshot_without_reboot = true
  depends_on = [ null_resource.aws08_delay ]
  tags = {
    Name = "${var.prefix}-instance-ami"
  }
}
