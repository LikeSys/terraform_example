# ~/terraform_example/aws_infra/03_ec2/output.tf

output "ami_id" {
  value = aws_ami_from_instance.aws08_ami.id
}