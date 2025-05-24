# =============================================================================
# LOCAL VALUES
# =============================================================================
# This file contains local values (computed values used multiple times)
# Locals help reduce repetition and make configurations more maintainable

locals {
  # -----------------------------------------------------------------------------
  # Naming Convention
  # -----------------------------------------------------------------------------
  # Consistent naming pattern across all resources
  common_name = "${var.environment}-${var.project_name}"
  
  # Unique suffix for resources that require global uniqueness
  unique_suffix = random_id.bucket_suffix.hex
  
  # Current timestamp for tracking creation time
  timestamp = formatdate("YYYY-MM-DD-hhmm", timestamp())
  
  # -----------------------------------------------------------------------------
  # Common Tags
  # -----------------------------------------------------------------------------
  # Base tags applied to all resources
  common_tags = {
    Name         = local.common_name
    Environment  = var.environment
    Project      = var.project_name
    Timestamp    = local.timestamp
    Terraform    = "true"
    Repository   = "15-Days-DevOps-Job-Journey"
    Day          = "Day-11"
  }
  
  # Additional tags for specific resource types
  ec2_tags = merge(local.common_tags, {
    Type = "compute"
    Role = "demo-instance"
  })
  
  storage_tags = merge(local.common_tags, {
    Type = "storage"
    Role = "demo-bucket"
  })
  
  security_tags = merge(local.common_tags, {
    Type = "security"
    Role = "demo-security-group"
  })
  
  # -----------------------------------------------------------------------------
  # Port Configurations
  # -----------------------------------------------------------------------------
  # Common ports used in the infrastructure
  ports = {
    ssh   = 22
    http  = 80
    https = 443
    app   = var.app_port
  }
  
  # -----------------------------------------------------------------------------
  # CIDR Blocks
  # -----------------------------------------------------------------------------
  # Common CIDR blocks for security groups
  cidrs = {
    anywhere = "0.0.0.0/0"
    vpc      = data.aws_vpc.default.cidr_block
  }
  
  # -----------------------------------------------------------------------------
  # User Data Template Variables
  # -----------------------------------------------------------------------------
  # Variables passed to the user data script
  user_data_vars = {
    environment = var.environment
    app_port    = var.app_port
    project     = var.project_name
    region      = var.aws_region
  }
  
  # -----------------------------------------------------------------------------
  # Conditional Logic
  # -----------------------------------------------------------------------------
  # Conditional values based on environment
  is_production = var.environment == "prod"
  is_development = var.environment == "dev"
  
  # Instance configuration based on environment
  instance_config = {
    monitoring = var.enable_detailed_monitoring
    encryption = true
    backup     = local.is_production
  }
  
  # -----------------------------------------------------------------------------
  # Resource Names
  # -----------------------------------------------------------------------------
  # Standardized resource names
  resource_names = {
    instance        = "${local.common_name}-instance"
    security_group  = "${local.common_name}-sg"
    key_pair       = "${local.common_name}-keypair"
    s3_bucket      = "${local.common_name}-bucket-${local.unique_suffix}"
    log_group      = "/aws/ec2/${local.common_name}"
  }
}