# ~/terraform_example/aws_infra/05_asg/output.tf

output "lt" {
  value = aws_launch_template.aws08_was_lt.id
}

