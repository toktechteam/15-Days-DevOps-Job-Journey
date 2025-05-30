# Day-12: Development Environment Configuration
# DevOps Course - ECS Multi-Environment Setup

# Basic Configuration
environment  = "dev"
project_name = "devops-course"
aws_region   = "us-east-1"

# Networking Configuration
vpc_cidr = "10.0.0.0/16"
public_subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24"
]
private_subnet_cidrs = [
  "10.0.10.0/24",
  "10.0.20.0/24"
]

# Application Configuration
frontend_port = 3000
backend_port  = 5000

# Database Configuration
db_name             = "devopsapp_dev"
db_username         = "admin"
db_password         = "DevOpsPassword123!"  # Change this in production!
mysql_version       = "8.0"
db_instance_class   = "db.t3.micro"
db_allocated_storage = 20
db_max_allocated_storage = 50

# Container Configuration
container_insights_enabled = true

# ECR Configuration
ecr_scan_on_push          = true
ecr_image_tag_mutability  = "MUTABLE"

# Monitoring and Logging
log_retention_days = 7

# Load Balancer Configuration
enable_deletion_protection = false
health_check_path = {
  frontend = "/"
  backend  = "/health"
}
health_check_interval    = 30
health_check_timeout     = 5
healthy_threshold        = 2
unhealthy_threshold      = 2

# Auto Scaling Configuration (Minimal for dev)
enable_autoscaling       = false
autoscaling_min_capacity = 1
autoscaling_max_capacity = 2
cpu_target_value         = 70
memory_target_value      = 80

# Security Configuration
enable_execute_command = true  # Enable for debugging in dev

# Backup Configuration (Minimal for dev)
backup_retention_period = 1
backup_window          = "03:00-04:00"
maintenance_window     = "Sun:04:00-Sun:05:00"

# Cost Optimization (Enable for dev)
enable_spot_instances = false  # Keep false for stability

# Performance Configuration
enable_performance_insights               = false
performance_insights_retention_period     = 7

# Additional Tags for Development
additional_tags = {
  Environment = "development"
  Purpose     = "learning"
  AutoShutdown = "true"  # For cost management
  Owner       = "devops-students"
  CostCenter  = "training"
}
