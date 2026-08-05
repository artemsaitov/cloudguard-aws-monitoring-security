output "aws_region" {
  description = "AWS Region selected for the CloudGuard deployment."
  value       = var.aws_region
}

output "project_name" {
  description = "CloudGuard project name."
  value       = var.project_name
}

output "vpc_id" {
  description = "ID of the CloudGuard VPC."
  value       = aws_vpc.cloudguard.id
}

output "dev_subnet_id" {
  description = "ID of the CloudGuard development subnet."
  value       = aws_subnet.dev.id
}

output "prod_subnet_id" {
  description = "ID of the CloudGuard production subnet."
  value       = aws_subnet.prod.id
}

output "dev_availability_zone" {
  description = "Availability Zone used by the development subnet."
  value       = aws_subnet.dev.availability_zone
}

output "prod_availability_zone" {
  description = "Availability Zone used by the production subnet."
  value       = aws_subnet.prod.availability_zone
}
