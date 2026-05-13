# ~/terraform_example/aws_infra/02_iam/output.tf

output "ec2_instance_profile_name" {
  value = aws_iam_instance_profile.aws08_ec2_instance_profile.name
}

