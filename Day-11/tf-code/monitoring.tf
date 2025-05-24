# =============================================================================
# MONITORING AND LOGGING RESOURCES
# =============================================================================
# This file contains all monitoring, logging, and observability resources
# including CloudWatch logs, metrics, alarms, and dashboards

# -----------------------------------------------------------------------------
# CloudWatch Log Groups
# -----------------------------------------------------------------------------

# Log group for application logs
resource "aws_cloudwatch_log_group" "demo_logs" {
  count = var.enable_cloudwatch_logs || local.is_production ? 1 : 0
  
  name              = local.resource_names.log_group
  retention_in_days = local.is_production ? 30 : 7
  
  tags = merge(local.common_tags, {
    Name = "${local.common_name}-logs"
    Type = "cloudwatch-log-group"
  })
}

# Log group for web server access logs
resource "aws_cloudwatch_log_group" "nginx_access_logs" {
  count = var.enable_cloudwatch_logs || local.is_production ? 1 : 0
  
  name              = "/aws/ec2/${local.common_name}/nginx/access"
  retention_in_days = local.is_production ? 14 : 3
  
  tags = merge(local.common_tags, {
    Name = "${local.common_name}-nginx-access-logs"
    Type = "cloudwatch-log-group"
  })
}

# Log group for web server error logs
resource "aws_cloudwatch_log_group" "nginx_error_logs" {
  count = var.enable_cloudwatch_logs || local.is_production ? 1 : 0
  
  name              = "/aws/ec2/${local.common_name}/nginx/error"
  retention_in_days = local.is_production ? 30 : 7
  
  tags = merge(local.common_tags, {
    Name = "${local.common_name}-nginx-error-logs"
    Type = "cloudwatch-log-group"
  })
}

# Log group for application-specific logs
resource "aws_cloudwatch_log_group" "app_logs" {
  count = var.enable_cloudwatch_logs || local.is_production ? 1 : 0
  
  name              = "/aws/ec2/${local.common_name}/application"
  retention_in_days = local.is_production ? 30 : 7
  
  tags = merge(local.common_tags, {
    Name = "${local.common_name}-app-logs"
    Type = "cloudwatch-log-group"
  })
}

# -----------------------------------------------------------------------------
# CloudWatch Custom Metrics
# -----------------------------------------------------------------------------

# Custom metric for application health
resource "aws_cloudwatch_log_metric_filter" "app_error_rate" {
  count = var.enable_cloudwatch_logs || local.is_production ? 1 : 0
  
  name           = "${local.common_name}-app-errors"
  log_group_name = aws_cloudwatch_log_group.app_logs[0].name
  pattern        = "ERROR"
  
  metric_transformation {
    name      = "ApplicationErrors"
    namespace = "CustomApp/${local.common_name}"
    value     = "1"
  }
}

# Custom metric for successful requests
resource "aws_cloudwatch_log_metric_filter" "successful_requests" {
  count = var.enable_cloudwatch_logs || local.is_production ? 1 : 0
  
  name           = "${local.common_name}-successful-requests"
  log_group_name = aws_cloudwatch_log_group.nginx_access_logs[0].name
  pattern        = "[timestamp, request_id, status_code=\"200\", ...]"
  
  metric_transformation {
    name      = "SuccessfulRequests"
    namespace = "CustomApp/${local.common_name}"
    value     = "1"
  }
}

# -----------------------------------------------------------------------------
# CloudWatch Alarms
# -----------------------------------------------------------------------------

# Application error rate alarm
resource "aws_cloudwatch_metric_alarm" "app_error_rate" {
  count = var.enable_cloudwatch_logs || local.is_production ? 1 : 0
  
  alarm_name          = "${local.common_name}-high-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "ApplicationErrors"
  namespace           = "CustomApp/${local.common_name}"
  period              = "300"
  statistic           = "Sum"
  threshold           = "10"
  alarm_description   = "This metric monitors application error rate"
  alarm_actions       = []  # Add SNS topic ARN for notifications
  
  tags = merge(local.common_tags, {
    Name = "${local.common_name}-error-rate-alarm"
    Type = "cloudwatch-alarm"
  })
}

# Disk space alarm
resource "aws_cloudwatch_metric_alarm" "disk_space" {
  count = var.enable_detailed_monitoring ? 1 : 0
  
  alarm_name          = "${local.common_name}-low-disk-space"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "DiskSpaceUtilization"
  namespace           = "CWAgent"
  period              = "300"
  statistic           = "Average"
  threshold           = "20"  # Alert when less than 20% space available
  alarm_description   = "This metric monitors available disk space"
  alarm_actions       = []  # Add SNS topic ARN for notifications
  
  dimensions = {
    InstanceId = aws_instance.demo_instance.id
    Filesystem = "/"
  }
  
  tags = merge(local.common_tags, {
    Name = "${local.common_name}-disk-space-alarm"
    Type = "cloudwatch-alarm"
  })
}

# Memory utilization alarm
resource "aws_cloudwatch_metric_alarm" "memory_utilization" {
  count = var.enable_detailed_monitoring ? 1 : 0
  
  alarm_name          = "${local.common_name}-high-memory"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "3"
  metric_name         = "MemoryUtilization"
  namespace           = "CWAgent"
  period              = "300"
  statistic           = "Average"
  threshold           = "85"
  alarm_description   = "This metric monitors memory utilization"
  alarm_actions       = []  # Add SNS topic ARN for notifications
  
  dimensions = {
    InstanceId = aws_instance.demo_instance.id
  }
  
  tags = merge(local.common_tags, {
    Name = "${local.common_name}-memory-alarm"
    Type = "cloudwatch-alarm"
  })
}

# -----------------------------------------------------------------------------
# CloudWatch Dashboard
# -----------------------------------------------------------------------------

# Custom dashboard for monitoring
resource "aws_cloudwatch_dashboard" "demo_dashboard" {
  count = var.enable_detailed_monitoring ? 1 : 0
  
  dashboard_name = "${local.common_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", "InstanceId", aws_instance.demo_instance.id],
            [".", "NetworkIn", ".", "."],
            [".", "NetworkOut", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "EC2 Instance Metrics"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["CustomApp/${local.common_name}", "ApplicationErrors"],
            [".", "SuccessfulRequests"]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Application Metrics"
          period  = 300
        }
      },
      {
        type   = "log"
        x      = 0
        y      = 12
        width  = 24
        height = 6

        properties = {
          query   = "SOURCE '/aws/ec2/${local.common_name}/application' | fields @timestamp, @message | sort @timestamp desc | limit 100"
          region  = var.aws_region
          title   = "Recent Application Logs"
        }
      }
    ]
  })
}

# -----------------------------------------------------------------------------
# SNS Topic for Alerts (Optional)
# -----------------------------------------------------------------------------

# SNS topic for CloudWatch alarms
resource "aws_sns_topic" "alerts" {
  count = local.is_production ? 1 : 0
  
  name = "${local.common_name}-alerts"
  
  tags = merge(local.common_tags, {
    Name = "${local.common_name}-alerts"
    Type = "sns-topic"
  })
}

# SNS topic subscription (email)
resource "aws_sns_topic_subscription" "email_alerts" {
  count = local.is_production ? 1 : 0
  
  topic_arn = aws_sns_topic.alerts[0].arn
  protocol  = "email"
  endpoint  = var.owner_email
}

# -----------------------------------------------------------------------------
# CloudWatch Events (EventBridge)
# -----------------------------------------------------------------------------

# CloudWatch event rule for EC2 state changes
resource "aws_cloudwatch_event_rule" "ec2_state_change" {
  count = local.is_production ? 1 : 0
  
  name        = "${local.common_name}-ec2-state-change"
  description = "Capture EC2 instance state changes"

  event_pattern = jsonencode({
    source      = ["aws.ec2"]
    detail-type = ["EC2 Instance State-change Notification"]
    detail = {
      instance-id = [aws_instance.demo_instance.id]
    }
  })
  
  tags = merge(local.common_tags, {
    Name = "${local.common_name}-ec2-event-rule"
    Type = "cloudwatch-event-rule"
  })
}

# CloudWatch event target (SNS)
resource "aws_cloudwatch_event_target" "sns_target" {
  count = local.is_production ? 1 : 0
  
  rule      = aws_cloudwatch_event_rule.ec2_state_change[0].name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.alerts[0].arn
}