locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Course      = "DevOps-Day12"
  }
 
  validate_rds_storage = var.db_max_allocated_storage >= var.db_allocated_storage
  is_autoscaling_valid = var.autoscaling_max_capacity >= var.autoscaling_min_capacity

  container_configs = {
    dev = {
      frontend_cpu    = 256
      frontend_memory = 512
      backend_cpu     = 256
      backend_memory  = 512
      desired_count   = 1
    }
    qa = {
      frontend_cpu    = 512
      frontend_memory = 1024
      backend_cpu     = 512
      backend_memory  = 1024
      desired_count   = 2
    }
    prod = {
      frontend_cpu    = 1024
      frontend_memory = 2048
      backend_cpu     = 1024
      backend_memory  = 2048
      desired_count   = 3
    }
  }
}
