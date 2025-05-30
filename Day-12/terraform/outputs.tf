
# Infrastructure Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways"
  value       = aws_nat_gateway.main[*].id
}

# Security Group Outputs
output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "ecs_security_group_id" {
  description = "ID of the ECS tasks security group"
  value       = aws_security_group.ecs_tasks.id
}

output "rds_security_group_id" {
  description = "ID of the RDS security group"
  value       = aws_security_group.rds.id
}

# ECR Outputs
output "ecr_frontend_repository_url" {
  description = "URL of the frontend ECR repository"
  value       = aws_ecr_repository.frontend.repository_url
}

output "ecr_backend_repository_url" {
  description = "URL of the backend ECR repository"
  value       = aws_ecr_repository.backend.repository_url
}

output "ecr_frontend_registry_id" {
  description = "Registry ID of the frontend ECR repository"
  value       = aws_ecr_repository.frontend.registry_id
}

output "ecr_backend_registry_id" {
  description = "Registry ID of the backend ECR repository"
  value       = aws_ecr_repository.backend.registry_id
}

# ECS Outputs
output "ecs_cluster_id" {
  description = "ID of the ECS cluster"
  value       = aws_ecs_cluster.main.id
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = aws_ecs_cluster.main.arn
}

output "ecs_frontend_service_name" {
  description = "Name of the frontend ECS service"
  value       = aws_ecs_service.frontend.name
}

output "ecs_backend_service_name" {
  description = "Name of the backend ECS service"
  value       = aws_ecs_service.backend.name
}

output "ecs_frontend_task_definition_arn" {
  description = "ARN of the frontend task definition"
  value       = aws_ecs_task_definition.frontend.arn
}

output "ecs_backend_task_definition_arn" {
  description = "ARN of the backend task definition"
  value       = aws_ecs_task_definition.backend.arn
}

# Load Balancer Outputs
output "load_balancer_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "load_balancer_zone_id" {
  description = "Hosted zone ID of the load balancer"
  value       = aws_lb.main.zone_id
}

output "load_balancer_arn" {
  description = "ARN of the load balancer"
  value       = aws_lb.main.arn
}

output "frontend_target_group_arn" {
  description = "ARN of the frontend target group"
  value       = aws_lb_target_group.frontend.arn
}

output "backend_target_group_arn" {
  description = "ARN of the backend target group"
  value       = aws_lb_target_group.backend.arn
}

# Application URLs
output "application_url" {
  description = "URL to access the application"
  value       = "http://${aws_lb.main.dns_name}"
}

output "backend_api_url" {
  description = "URL to access the backend API"
  value       = "http://${aws_lb.main.dns_name}/api"
}

# Database Outputs
output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.mysql.endpoint
  sensitive   = true
}

output "rds_port" {
  description = "RDS instance port"
  value       = aws_db_instance.mysql.port
}

output "rds_database_name" {
  description = "RDS database name"
  value       = aws_db_instance.mysql.db_name
}

output "rds_username" {
  description = "RDS database username"
  value       = aws_db_instance.mysql.username
  sensitive   = true
}

output "rds_availability_zone" {
  description = "RDS instance availability zone"
  value       = aws_db_instance.mysql.availability_zone
}

output "rds_backup_window" {
  description = "RDS backup window"
  value       = aws_db_instance.mysql.backup_window
}

output "rds_maintenance_window" {
  description = "RDS maintenance window"
  value       = aws_db_instance.mysql.maintenance_window
}

# CloudWatch Outputs
output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group for ECS"
  value       = aws_cloudwatch_log_group.ecs.name
}

output "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch log group for ECS"
  value       = aws_cloudwatch_log_group.ecs.arn
}

# IAM Outputs
output "ecs_task_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  value       = aws_iam_role.ecs_task_execution.arn
}

output "ecs_task_execution_role_name" {
  description = "Name of the ECS task execution role"
  value       = aws_iam_role.ecs_task_execution.name
}

# Environment and Project Information
output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "project_name" {
  description = "Project name"
  value       = var.project_name
}

output "aws_region" {
  description = "AWS region"
  value       = var.aws_region
}

# Connection Information for Jenkins
output "jenkins_deployment_info" {
  description = "Information needed for Jenkins deployment"
  value = {
    cluster_name                = aws_ecs_cluster.main.name
    frontend_service_name       = aws_ecs_service.frontend.name
    backend_service_name        = aws_ecs_service.backend.name
    frontend_task_definition    = split(":", aws_ecs_task_definition.frontend.arn)[6]
    backend_task_definition     = split(":", aws_ecs_task_definition.backend.arn)[6]
    frontend_ecr_repository_url = aws_ecr_repository.frontend.repository_url
    backend_ecr_repository_url  = aws_ecr_repository.backend.repository_url
    load_balancer_dns           = aws_lb.main.dns_name
    application_url             = "http://${aws_lb.main.dns_name}"
    backend_api_url             = "http://${aws_lb.main.dns_name}/api"
  }
}

# Resource Summary
output "resource_summary" {
  description = "Summary of created resources"
  value = {
    vpc_id               = aws_vpc.main.id
    public_subnets_count = length(aws_subnet.public)
    private_subnets_count = length(aws_subnet.private)
    ecs_cluster_name     = aws_ecs_cluster.main.name
    rds_instance_id      = aws_db_instance.mysql.id
    load_balancer_name   = aws_lb.main.name
    ecr_repositories = {
      frontend = aws_ecr_repository.frontend.name
      backend  = aws_ecr_repository.backend.name
    }
    security_groups = {
      alb       = aws_security_group.alb.id
      ecs_tasks = aws_security_group.ecs_tasks.id
      rds       = aws_security_group.rds.id
    }
  }
}

# RDS OutPut

output "rds_storage_valid" {
  value = local.validate_rds_storage
  description = "Should be true if db_max_allocated_storage >= db_allocated_storage"
}

# ASG OutPut
output "autoscaling_capacity_valid" {
  value       = local.is_autoscaling_valid
  description = "Should be true if max capacity >= min capacity"
}

# Cost Estimation Tags
output "cost_allocation_tags" {
  description = "Tags for cost allocation and tracking"
  value = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Course      = "DevOps-Day12"
  }
}
