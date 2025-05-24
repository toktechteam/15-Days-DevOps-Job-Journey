# =============================================================================
# COMPUTE RESOURCES
# =============================================================================
# This file contains all compute-related resources including EC2 instances,
# launch templates, and related compute configurations

# -----------------------------------------------------------------------------
# Random ID for Unique Resource Names
# -----------------------------------------------------------------------------

# Generate random ID for resources that need global uniqueness
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# -----------------------------------------------------------------------------
# EC2 Instance
# -----------------------------------------------------------------------------

# Main demo EC2 instance
resource "aws_instance" "demo_instance" {
  # AMI and instance configuration
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  
  # Network configuration
  subnet_id                   = tolist(data.aws_subnets.default.ids)[0]
  vpc_security_group_ids      = [aws_security_group.demo_sg.id]
  associate_public_ip_address = true
  
  # Key pair for SSH access (conditional)
  key_name = var.enable_ssh_access ? aws_key_pair.demo_key[0].key_name : null
  
  # IAM role (conditional for production)
  iam_instance_profile = local.is_production && length(aws_iam_instance_profile.ec2_profile) > 0 ? aws_iam_instance_profile.ec2_profile[0].name : null
  
  # Monitoring configuration
  monitoring = var.enable_detailed_monitoring
  
  # User data script for instance initialization
  user_data = base64encode(templatefile("${path.module}/user_data.sh", local.user_data_vars))
  
  # Storage configuration
  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.root_volume_size
    encrypted             = true
    delete_on_termination = true
    
    # Use default KMS key for encryption
    kms_key_id = data.aws_ebs_default_kms_key.current.key_arn
    
    tags = merge(local.ec2_tags, {
      Name = "${local.resource_names.instance}-root-volume"
      Type = "root-volume"
    })
  }
  
  # Instance metadata service configuration (IMDSv2)
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"  # Require IMDSv2
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }
  
  # Credit specification for T3 instances
  credit_specification {
    cpu_credits = "standard"  # or "unlimited" for burstable performance
  }
  
  # Enable source/destination check (default: true)
  source_dest_check = true
  
  # Placement configuration
  availability_zone = data.aws_availability_zones.available.names[0]
  
  # Tags for the instance
  tags = merge(local.ec2_tags, {
    Name = local.resource_names.instance
    Role = "demo-web-server"
  })
  
  # Additional volume tags
  volume_tags = merge(local.ec2_tags, {
    Name = "${local.resource_names.instance}-volume"
    Type = "ebs-volume"
  })
  
  # Lifecycle management
  lifecycle {
    # Prevent accidental deletion in production
    prevent_destroy = false  # Set to true for production
    
    # Ignore changes to AMI (to prevent replacement during AMI updates)
    ignore_changes = [
      ami,
      user_data  # Ignore user_data changes to prevent instance replacement
    ]
  }
  
  # Dependencies
  depends_on = [
    aws_security_group.demo_sg,
    aws_key_pair.demo_key
  ]
}

# -----------------------------------------------------------------------------
# Elastic IP (Optional)
# -----------------------------------------------------------------------------

# Elastic IP for static public IP address (uncomment if needed)
# resource "aws_eip" "demo_eip" {
#   count = var.environment == "prod" ? 1 : 0
#   
#   instance = aws_instance.demo_instance.id
#   domain   = "vpc"
#   
#   tags = merge(local.ec2_tags, {
#     Name = "${local.resource_names.instance}-eip"
#     Type = "elastic-ip"
#   })
#   
#   depends_on = [aws_instance.demo_instance]
# }

# -----------------------------------------------------------------------------
# Launch Template (for future Auto Scaling Groups)
# -----------------------------------------------------------------------------

# Launch template for potential auto scaling group usage
resource "aws_launch_template" "demo_template" {
  count = var.environment == "prod" ? 1 : 0
  
  name_prefix   = "${local.common_name}-template-"
  description   = "Launch template for ${local.common_name} instances"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  
  # Key pair
  key_name = var.enable_ssh_access ? aws_key_pair.demo_key[0].key_name : null
  
  # Security groups
  vpc_security_group_ids = [aws_security_group.demo_sg.id]
  
  # IAM instance profile
  iam_instance_profile {
    name = length(aws_iam_instance_profile.ec2_profile) > 0 ? aws_iam_instance_profile.ec2_profile[0].name : null
  }
  
  # User data
  user_data = base64encode(templatefile("${path.module}/user_data.sh", local.user_data_vars))
  
  # Block device mappings
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = var.root_volume_size
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }
  
  # Instance metadata service configuration
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }
  
  # Credit specification for T3 instances
  credit_specification {
    cpu_credits = "standard"
  }
  
  # Monitoring
  monitoring {
    enabled = var.enable_detailed_monitoring
  }
  
  # Network interfaces
  network_interfaces {
    associate_public_ip_address = true
    delete_on_termination       = true
    security_groups             = [aws_security_group.demo_sg.id]
  }
  
  # Tags for instances launched from this template
  tag_specifications {
    resource_type = "instance"
    tags = merge(local.ec2_tags, {
      Name        = "${local.common_name}-asg-instance"
      LaunchedBy  = "AutoScalingGroup"
    })
  }
  
  tag_specifications {
    resource_type = "volume"
    tags = merge(local.ec2_tags, {
      Name = "${local.common_name}-asg-volume"
      Type = "asg-volume"
    })
  }
  
  tags = merge(local.ec2_tags, {
    Name = "${local.common_name}-launch-template"
    Type = "launch-template"
  })
  
  lifecycle {
    create_before_destroy = true
  }
}

# -----------------------------------------------------------------------------
# CloudWatch Alarms for Monitoring
# -----------------------------------------------------------------------------

# CPU utilization alarm
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  count = var.enable_detailed_monitoring ? 1 : 0
  
  alarm_name          = "${local.common_name}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = []  # Add SNS topic ARN for notifications
  
  dimensions = {
    InstanceId = aws_instance.demo_instance.id
  }
  
  tags = merge(local.ec2_tags, {
    Name = "${local.common_name}-cpu-alarm"
    Type = "cloudwatch-alarm"
  })
}

# Status check alarm
resource "aws_cloudwatch_metric_alarm" "status_check" {
  count = var.enable_detailed_monitoring ? 1 : 0
  
  alarm_name          = "${local.common_name}-status-check"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "0"
  alarm_description   = "This metric monitors instance status check"
  alarm_actions       = []  # Add SNS topic ARN for notifications
  
  dimensions = {
    InstanceId = aws_instance.demo_instance.id
  }
  
  tags = merge(local.ec2_tags, {
    Name = "${local.common_name}-status-alarm"
    Type = "cloudwatch-alarm"
  })
}