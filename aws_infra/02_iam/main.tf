# aws_infra/iam/main.tf

# 1. EC2 Role (Jenkins & WAS 공용 혹은 Jenkins 전용)
resource "aws_iam_role" "aws08_ec2_role" {
  name = "${var.prefix}_ec2_role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": { "Service": "ec2.amazonaws.com" }
        Action: "sts:AssumeRole" // AWS Security Token Service
      }
    ]
  })
}

# [필수] SSM 정책 연결: 세션 매니저 접속용
resource "aws_iam_role_policy_attachment" "aws08_ssm_attach" {
  role       = aws_iam_role.aws08_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# [필수] S3 정책 연결: 배포 파일 업로드/다운로드용
resource "aws_iam_role_policy_attachment" "aws08_s3_attach" {
  role       = aws_iam_role.aws08_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# 2. EC2 인스턴스 프로파일
resource "aws_iam_instance_profile" "aws08_ec2_instance_profile" {
  name = "${var.prefix}-ec2-instance-profile"
  role = aws_iam_role.aws08_ec2_role.name
}

# 3. Code Deploy Service Role
resource "aws_iam_role" "aws08_codedeploy_service_role" {
  name = "${var.prefix}-codedeploy-service-role"

  assume_role_policy = jsonencode({
    Version: "2012-10-17",
    Statement: [{
      Effect: "Allow",
      Principal: {
        Service: "codedeploy.amazonaws.com"
      },
      Action: "sts:AssumeRole"
    }]
  })
}

# Code Deploy Service 정책 연결
resource "aws_iam_role_policy_attachment" "aws08_codedeploy_attach" {
  role       = aws_iam_role.aws08_codedeploy_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

