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

output "dev_instance_id" {
  description = "Instance ID of the CloudGuard development server."
  value       = aws_instance.dev.id
}

output "prod_instance_id" {
  description = "Instance ID of the CloudGuard production server."
  value       = aws_instance.prod.id
}

output "dev_private_ip" {
  description = "Private IP address of the development server."
  value       = aws_instance.dev.private_ip
}

output "prod_private_ip" {
  description = "Private IP address of the production server."
  value       = aws_instance.prod.private_ip
}

output "dev_public_ip" {
  description = "Public IP address of the development server."
  value       = aws_instance.dev.public_ip
}

output "prod_public_ip" {
  description = "Public IP address of the production server."
  value       = aws_instance.prod.public_ip
}

output "ec2_instance_profile" {
  description = "IAM instance profile attached to the CloudGuard servers."
  value       = aws_iam_instance_profile.ec2_monitoring.name
}

output "operational_sns_topic_arn" {
  description = "SNS topic used for operational CloudWatch alerts."
  value       = aws_sns_topic.operational_alerts.arn
}

output "cloudwatch_dashboard_name" {
  description = "Name of the CloudGuard operations dashboard."
  value       = aws_cloudwatch_dashboard.cloudguard.dashboard_name
}

output "cloudwatch_alarm_names" {
  description = "Names of the CloudGuard operational alarms."

  value = [
    aws_cloudwatch_metric_alarm.dev_high_cpu.alarm_name,
    aws_cloudwatch_metric_alarm.prod_low_disk.alarm_name,
    aws_cloudwatch_metric_alarm.prod_high_memory.alarm_name
  ]
}