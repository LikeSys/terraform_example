# ~/terraform_example/aws_infra/01_network/output.tf

output "vpc_id" {
  value = aws_vpc.aws08_vpc.id
}

output "public_subnet_ids" {
  value = aws_subnet.aws08_public_subnet[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.aws08_private_subnet[*].id
}

output "ssh_sg_id" {
  value = aws_security_group.aws08_ssh_sg.id
}

output "http_sg_id" {
  value = aws_security_group.aws08_http_sg.id
}
