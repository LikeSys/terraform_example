# aws_infra/alb/variable.tf
variable "region" { type = string }
variable "prefix" { type = string }
variable "certificate_arn" { type = string }