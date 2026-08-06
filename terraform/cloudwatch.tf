resource "aws_cloudwatch_metric_alarm" "dev_high_cpu" {
  alarm_name        = "${local.name_prefix}-dev-high-cpu"
  alarm_description = "Development EC2 CPU utilization is at or above 85 percent for two consecutive minutes."

  namespace   = "AWS/EC2"
  metric_name = "CPUUtilization"
  statistic   = "Average"
  period      = 60

  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = 85

  evaluation_periods  = 2
  datapoints_to_alarm = 2

  dimensions = {
    InstanceId = aws_instance.dev.id
  }

  alarm_actions = [aws_sns_topic.operational_alerts.arn]
  ok_actions    = [aws_sns_topic.operational_alerts.arn]

  treat_missing_data = "notBreaching"

  tags = {
    Name        = "${local.name_prefix}-dev-high-cpu"
    Environment = "Dev"
    IssueType   = "HighCPU"
  }
}

resource "aws_cloudwatch_metric_alarm" "prod_low_disk" {
  alarm_name        = "${local.name_prefix}-prod-low-disk"
  alarm_description = "Production root filesystem usage is at or above 80 percent for two consecutive minutes."

  namespace   = "CWAgent"
  metric_name = "disk_used_percent"
  statistic   = "Average"
  period      = 60

  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = 80

  evaluation_periods  = 2
  datapoints_to_alarm = 2

  dimensions = {
    InstanceId = aws_instance.prod.id
  }

  alarm_actions = [aws_sns_topic.operational_alerts.arn]
  ok_actions    = [aws_sns_topic.operational_alerts.arn]

  treat_missing_data = "notBreaching"

  tags = {
    Name        = "${local.name_prefix}-prod-low-disk"
    Environment = "Production"
    IssueType   = "LowDisk"
  }
}
resource "aws_cloudwatch_metric_alarm" "prod_high_memory" {
  alarm_name        = "${local.name_prefix}-prod-high-memory"
  alarm_description = "Production EC2 memory usage is at or above 85 percent for two consecutive minutes."

  namespace   = "CWAgent"
  metric_name = "mem_used_percent"
  statistic   = "Average"
  period      = 60

  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = 85

  evaluation_periods  = 2
  datapoints_to_alarm = 2

  dimensions = {
    InstanceId = aws_instance.prod.id
  }

  alarm_actions = [aws_sns_topic.operational_alerts.arn]
  ok_actions    = [aws_sns_topic.operational_alerts.arn]

  treat_missing_data = "notBreaching"

  tags = {
    Name        = "${local.name_prefix}-prod-high-memory"
    Environment = "Production"
    IssueType   = "HighMemory"
  }
}

resource "aws_cloudwatch_dashboard" "cloudguard" {
  dashboard_name = "${local.name_prefix}-operations-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "text"
        x      = 0
        y      = 0
        width  = 24
        height = 2

        properties = {
          markdown = <<-EOT
            # CloudGuard Operations Dashboard

            Monitoring development and production EC2 environments.

            **Managed by Terraform**
          EOT
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 2
        width  = 12
        height = 6

        properties = {
          title  = "Development CPU Utilization"
          view   = "timeSeries"
          region = var.aws_region
          period = 60
          stat   = "Average"

          metrics = [
            [
              "AWS/EC2",
              "CPUUtilization",
              "InstanceId",
              aws_instance.dev.id,
              {
                label = "Dev CPU"
                color = "#1f77b4"
              }
            ]
          ]

          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }

          annotations = {
            horizontal = [
              {
                label = "High CPU threshold"
                value = 85
                color = "#d62728"
              }
            ]
          }
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 2
        width  = 12
        height = 6

        properties = {
          title  = "Production Disk Usage"
          view   = "timeSeries"
          region = var.aws_region
          period = 60
          stat   = "Average"

          metrics = [
            [
              "CWAgent",
              "disk_used_percent",
              "InstanceId",
              aws_instance.prod.id,
              {
                label = "Prod Disk Usage"
                color = "#ff7f0e"
              }
            ]
          ]

          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }

          annotations = {
            horizontal = [
              {
                label = "Low disk threshold"
                value = 80
                color = "#d62728"
              }
            ]
          }
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 8
        width  = 12
        height = 6

        properties = {
          title  = "Production Memory Usage"
          view   = "timeSeries"
          region = var.aws_region
          period = 60
          stat   = "Average"

          metrics = [
            [
              "CWAgent",
              "mem_used_percent",
              "InstanceId",
              aws_instance.prod.id,
              {
                label = "Prod Memory Usage"
                color = "#2ca02c"
              }
            ]
          ]

          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }

          annotations = {
            horizontal = [
              {
                label = "High memory threshold"
                value = 85
                color = "#d62728"
              }
            ]
          }
        }
      },
      {
        type   = "alarm"
        x      = 12
        y      = 8
        width  = 12
        height = 6

        properties = {
          title = "CloudGuard Alarm Status"

          alarms = [
            aws_cloudwatch_metric_alarm.dev_high_cpu.arn,
            aws_cloudwatch_metric_alarm.prod_low_disk.arn,
            aws_cloudwatch_metric_alarm.prod_high_memory.arn
          ]
        }
      }
    ]
  })
}
