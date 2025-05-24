# =============================================================================
# OUTPUT VALUES
# =============================================================================
# This file defines all output values that will be displayed after 
# terraform apply completes. Outputs are useful for:
# - Displaying important resource information
# - Passing values to other Terraform configurations
# - Integration with CI/CD pipelines

# -----------------------------------------------------------------------------
# Instance Information Outputs
# -----------------------------------------------------------------------------

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.demo_instance.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.demo_instance.public_ip
}

output "instance_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.demo_instance.private_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.demo_instance.public_dns
}

output "instance_private_dns" {
  description = "Private DNS name of the EC2 instance"
  value       = aws_instance.demo_instance.private_dns
}

output "instance_state" {
  description = "Current state of the EC2 instance"
  value       = aws_instance.demo_instance.instance_state
}

output "instance_type" {
  description = "Type of the EC2 instance"
  value       = aws_instance.demo_instance.instance_type
}

output "availability_zone" {
  description = "Availability zone where the instance is running"
  value       = aws_instance.demo_instance.availability_zone
}

# -----------------------------------------------------------------------------
# Network and Security Outputs
# -----------------------------------------------------------------------------

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.demo_sg.id
}

output "security_group_name" {
  description = "Name of the security group"
  value       = aws_security_group.demo_sg.name
}

output "vpc_id" {
  description = "ID of the VPC where resources are created"
  value       = data.aws_vpc.default.id
}

output "subnet_id" {
  description = "ID of the subnet where the instance is running"
  value       = aws_instance.demo_instance.subnet_id
}

output "key_pair_name" {
  description = "Name of the key pair (if SSH access is enabled)"
  value       = var.enable_ssh_access ? aws_key_pair.demo_key[0].key_name : "SSH access disabled"
}

# -----------------------------------------------------------------------------
# Storage Outputs
# -----------------------------------------------------------------------------

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.demo_bucket.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.demo_bucket.arn
}

output "s3_bucket_domain_name" {
  description = "Domain name of the S3 bucket"
  value       = aws_s3_bucket.demo_bucket.bucket_domain_name
}

output "root_volume_id" {
  description = "ID of the root EBS volume"
  value       = aws_instance.demo_instance.root_block_device[0].volume_id
}

output "additional_volume_id" {
  description = "ID of the additional EBS volume (if created)"
  value       = var.environment == "prod" && length(aws_ebs_volume.demo_data_volume) > 0 ? aws_ebs_volume.demo_data_volume[0].id : "No additional volume created"
}

# -----------------------------------------------------------------------------
# Application Access Outputs
# -----------------------------------------------------------------------------

output "application_url" {
  description = "URL to access the demo application"
  value       = "http://${aws_instance.demo_instance.public_ip}"
}

output "application_direct_url" {
  description = "Direct URL to the Node.js application"
  value       = "http://${aws_instance.demo_instance.public_ip}:${var.app_port}"
}

output "health_check_url" {
  description = "Health check endpoint URL"
  value       = "http://${aws_instance.demo_instance.public_ip}/health"
}

# -----------------------------------------------------------------------------
# Connection Information Outputs
# -----------------------------------------------------------------------------

output "ssh_connection_command" {
  description = "Command to SSH into the instance"
  value       = var.enable_ssh_access ? "ssh -i ${aws_key_pair.demo_key[0].key_name}.pem ec2-user@${aws_instance.demo_instance.public_ip}" : "SSH access is disabled"
}

output "ssh_user" {
  description = "SSH username for the instance"
  value       = "ec2-user"
}

# -----------------------------------------------------------------------------
# Regional Information Outputs
# -----------------------------------------------------------------------------

output "aws_region" {
  description = "AWS region where resources are deployed"
  value       = data.aws_region.current.name
}

output "availability_zones" {
  description = "Available AZs in the region"
  value       = data.aws_availability_zones.available.names
}

output "account_id" {
  description = "AWS account ID"
  value       = data.aws_caller_identity.current.account_id
  sensitive   = true  # Mark as sensitive to avoid displaying in logs
}

# -----------------------------------------------------------------------------
# Monitoring Outputs
# -----------------------------------------------------------------------------

output "cloudwatch_log_group" {
  description = "CloudWatch log group name (if enabled)"
  value       = var.enable_cloudwatch_logs || local.is_production ? aws_cloudwatch_log_group.demo_logs[0].name : "CloudWatch logs disabled"
}

output "cloudwatch_dashboard_url" {
  description = "URL to CloudWatch dashboard (if enabled)"
  value = var.enable_detailed_monitoring ? "https://${data.aws_region.current.name}.console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#dashboards:name=${local.common_name}-dashboard" : "CloudWatch dashboard disabled"
}

output "sns_topic_arn" {
  description = "SNS topic ARN for alerts (if enabled)"
  value       = local.is_production && length(aws_sns_topic.alerts) > 0 ? aws_sns_topic.alerts[0].arn : "SNS alerts disabled"
}

# -----------------------------------------------------------------------------
# Environment and Configuration Outputs
# -----------------------------------------------------------------------------

output "environment" {
  description = "Current environment"
  value       = var.environment
}

output "project_name" {
  description = "Project name"
  value       = var.project_name
}

output "deployment_timestamp" {
  description = "Timestamp when the infrastructure was deployed"
  value       = local.timestamp
}

output "terraform_workspace" {
  description = "Current Terraform workspace"
  value       = terraform.workspace
}

# -----------------------------------------------------------------------------
# Resource Count Outputs
# -----------------------------------------------------------------------------

output "demo_files_created" {
  description = "Number of demo files created in S3"
  value       = var.create_demo_files
}

output "security_group_rules_count" {
  description = "Number of security group rules created"
  value = length([
    aws_security_group_rule.http_ingress,
    aws_security_group_rule.https_ingress,
    aws_security_group_rule.app_ingress,
    aws_security_group_rule.icmp_ingress,
    aws_security_group_rule.all_egress
  ]) + (var.enable_ssh_access ? 1 : 0)
}

# -----------------------------------------------------------------------------
# Cost and Resource Information Outputs
# -----------------------------------------------------------------------------

output "estimated_monthly_cost" {
  description = "Estimated monthly cost breakdown (approximate)"
  value = {
    ec2_instance = "~$8.50/month (t3.micro)"
    ebs_storage  = "~$2.00/month (20GB gp3)"
    data_transfer = "First 1GB free, then $0.09/GB"
    s3_storage   = "First 50TB: $0.023/GB/month"
    cloudwatch   = "First 10 metrics free, then $0.30/metric/month"
    note        = "Costs may vary based on usage and region"
  }
}

# -----------------------------------------------------------------------------
# Quick Start Outputs
# -----------------------------------------------------------------------------

output "quick_start_commands" {
  description = "Quick commands to get started"
  value = {
    test_application = "curl http://${aws_instance.demo_instance.public_ip}"
    test_health      = "curl http://${aws_instance.demo_instance.public_ip}/health"
    view_logs        = "ssh -i ${var.enable_ssh_access ? "${aws_key_pair.demo_key[0].key_name}.pem" : "YOUR_KEY.pem"} ec2-user@${aws_instance.demo_instance.public_ip} 'sudo journalctl -u demo-app -f'"
    list_s3_files    = "aws s3 ls s3://${aws_s3_bucket.demo_bucket.bucket}/ --recursive"
  }
}

# -----------------------------------------------------------------------------
# Next Steps Outputs
# -----------------------------------------------------------------------------

output "next_steps" {
  description = "Recommended next steps for learning"
  value = [
    "1. Test the application: curl http://${aws_instance.demo_instance.public_ip}",
    "2. Check the health endpoint: curl http://${aws_instance.demo_instance.public_ip}/health",
    "3. Explore the S3 bucket: aws s3 ls s3://${aws_s3_bucket.demo_bucket.bucket}/",
    "4. Monitor resources in CloudWatch console",
    "5. Practice: modify variables in terraform.tfvars and apply changes",
    "6. Clean up: run 'terraform destroy' when finished"
  ]
}

# -----------------------------------------------------------------------------
# Troubleshooting Outputs
# -----------------------------------------------------------------------------

output "troubleshooting_info" {
  description = "Common troubleshooting information"
  value = {
    instance_logs     = "ssh to instance and check: sudo journalctl -u demo-app"
    nginx_status      = "ssh to instance and run: sudo systemctl status nginx"
    security_groups   = "Check security group rules allow traffic on ports 80, 443, ${var.app_port}"
    public_ip_access  = "Ensure instance has public IP: ${aws_instance.demo_instance.public_ip}"
    ssh_troubleshoot  = var.enable_ssh_access ? "SSH key: ${aws_key_pair.demo_key[0].key_name}.pem, User: ec2-user" : "SSH access is disabled"
  }
}