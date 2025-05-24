# =============================================================================
# PROVIDER CONFIGURATIONS
# =============================================================================
# This file contains all provider configurations
# Providers are plugins that allow Terraform to interact with cloud platforms

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
  
  # Default tags applied to ALL resources created by this provider
  # This ensures consistent tagging across your entire infrastructure
  default_tags {
    tags = {
      Project     = "DevOps-Demo"
      Environment = var.environment
      Day         = "Day-11"
      CreatedBy   = "Terraform"
      Owner       = var.owner_email
      ManagedBy   = "Terraform"
    }
  }
}

# Configure the Random Provider (for generating unique names)
provider "random" {
  # No specific configuration needed for random provider
}