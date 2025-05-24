# =============================================================================
# TERRAFORM VERSION CONSTRAINTS AND REQUIRED PROVIDERS
# =============================================================================
# This file defines Terraform version requirements and required providers
# Keep this separate to easily manage version upgrades across environments

terraform {
  # Specify minimum Terraform version
  required_version = ">= 1.0"
  
  # Define required providers with version constraints
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"  # Allow 5.x versions, but not 6.x
    }
    
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
  
  # Backend configuration for remote state storage
  # Uncomment and configure for team collaboration
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "day11/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "terraform-locks"
  #   encrypt        = true
  # }
}