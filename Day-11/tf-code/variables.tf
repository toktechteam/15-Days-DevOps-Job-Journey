# =============================================================================
# INPUT VARIABLES
# =============================================================================
# This file defines all input variables used in the Terraform configuration
# Variables make your code reusable and configurable across environments

# -----------------------------------------------------------------------------
# AWS Configuration Variables
# -----------------------------------------------------------------------------

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
  
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.aws_region))
    error_message = "AWS region must be in the format: us-east-1, eu-west-1, etc."
  }
}

# -----------------------------------------------------------------------------
# Environment Configuration Variables
# -----------------------------------------------------------------------------

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "devops-demo"
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

# -----------------------------------------------------------------------------
# Contact and Ownership Variables
# -----------------------------------------------------------------------------

variable "owner_email" {
  description = "Email of the resource owner"
  type        = string
  default     = "devops-student@example.com"
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.owner_email))
    error_message = "Owner email must be a valid email address."
  }
}

# -----------------------------------------------------------------------------
# EC2 Instance Variables
# -----------------------------------------------------------------------------

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
  
  validation {
    condition = contains([
      "t3.micro", "t3.small", "t3.medium",
      "t2.micro", "t2.small", "t2.medium"
    ], var.instance_type)
    error_message = "Instance type must be one of the allowed types."
  }
}

variable "root_volume_size" {
  description = "Size of the root EBS volume in GB"
  type        = number
  default     = 20
  
  validation {
    condition     = var.root_volume_size >= 8 && var.root_volume_size <= 100
    error_message = "Root volume size must be between 8 and 100 GB."
  }
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring for EC2 instance"
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# Security Variables
# -----------------------------------------------------------------------------

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH to instances"
  type        = string
  default     = "0.0.0.0/0"  # WARNING: Restrict this in production!
  
  validation {
    condition     = can(cidrhost(var.allowed_ssh_cidr, 0))
    error_message = "Allowed SSH CIDR must be a valid CIDR block."
  }
}

variable "enable_ssh_access" {
  description = "Enable SSH access to the instance"
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# S3 Configuration Variables
# -----------------------------------------------------------------------------

variable "enable_s3_versioning" {
  description = "Enable S3 bucket versioning"
  type        = bool
  default     = true
}

variable "s3_encryption_algorithm" {
  description = "S3 bucket encryption algorithm"
  type        = string
  default     = "AES256"
  
  validation {
    condition     = contains(["AES256", "aws:kms"], var.s3_encryption_algorithm)
    error_message = "S3 encryption algorithm must be either AES256 or aws:kms."
  }
}

# -----------------------------------------------------------------------------
# Application Configuration Variables
# -----------------------------------------------------------------------------

variable "app_port" {
  description = "Port on which the demo application runs"
  type        = number
  default     = 3000
  
  validation {
    condition     = var.app_port > 1000 && var.app_port < 65536
    error_message = "Application port must be between 1000 and 65535."
  }
}

# -----------------------------------------------------------------------------
# Advanced Configuration Variables
# -----------------------------------------------------------------------------

variable "demo_environments" {
  description = "Map of demo environments with their configurations"
  type = map(object({
    instance_type = string
    description   = string
  }))
  default = {
    "dev" = {
      instance_type = "t3.micro"
      description   = "Development environment"
    }
    "staging" = {
      instance_type = "t3.small"
      description   = "Staging environment"
    }
  }
}

variable "create_demo_files" {
  description = "Number of demo files to create in S3 bucket"
  type        = number
  default     = 3
  
  validation {
    condition     = var.create_demo_files >= 0 && var.create_demo_files <= 10
    error_message = "Number of demo files must be between 0 and 10."
  }
}

variable "enable_cloudwatch_logs" {
  description = "Enable CloudWatch logs (only for production)"
  type        = bool
  default     = false
}