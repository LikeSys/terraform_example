# ~/terraform_example/aws_infra/04_alb/output.tf

output "was_sg"{
  value = aws_lb_target_group.aws08_alb_was_group.id
}

output "was_tg"{
  value = aws_lb_target_group.aws08_alb_was_group.arn
}

output "jenkins_sg"{
  value = aws_lb_target_group.aws08_alb_jenkins_group.id
}
  
output "jenkins_tg"{
  value = aws_lb_target_group.aws08_alb_jenkins_group.arn
}
