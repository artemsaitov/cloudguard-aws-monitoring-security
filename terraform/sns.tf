resource "aws_sns_topic" "operational_alerts" {
  name = "${local.name_prefix}-operational-alerts"

  tags = {
    Name    = "${local.name_prefix}-operational-alerts"
    Purpose = "OperationalMonitoring"
  }
}

resource "aws_sns_topic_subscription" "operational_email" {
  topic_arn = aws_sns_topic.operational_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}
