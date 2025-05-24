# =============================================================================
# DATA SOURCES
# =============================================================================
# This file contains all data sources that fetch information about 
# existing resources in AWS that we don't manage with this Terraform config

# -----------------------------------------------------------------------------
# AMI Data Sources
# -----------------------------------------------------------------------------

# Get the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  
  filter {
    name   = "state"
    values = ["available"]
  }
}

# Alternative: Get Ubuntu 20.04 LTS AMI (commented out)
# data "aws_ami" "ubuntu" {
#   most_recent = true
#   owners      = ["099720109477"] # Canonical
#   
#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
#   }
#   
#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }
# }

# -----------------------------------------------------------------------------
# Availability Zones Data Sources
# -----------------------------------------------------------------------------

# Get all available availability zones in the current region
data "aws_availability_zones" "available" {
  state = "available"
  
  # Exclude local zones and wavelength zones
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

# Get available AZs that support the instance type
data "aws_ec2_instance_type_offerings" "available" {
  filter {
    name   = "instance-type"
    values = [var.instance_type]
  }
  
  filter {
    name   = "location"
    values = data.aws_availability_zones.available.names
  }
  
  location_type = "availability-zone"
}

# -----------------------------------------------------------------------------
# VPC and Networking Data Sources
# -----------------------------------------------------------------------------

# Get the default VPC
data "aws_vpc" "default" {
  default = true
}

# Get all subnets in the default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  
  filter {
    name   = "state"
    values = ["available"]
  }
}

# Get subnet details for each subnet
data "aws_subnet" "default" {
  for_each = toset(data.aws_subnets.default.ids)
  id       = each.value
}

# Get the default internet gateway
data "aws_internet_gateway" "default" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# -----------------------------------------------------------------------------
# Security and Identity Data Sources
# -----------------------------------------------------------------------------

# Get current AWS caller identity
data "aws_caller_identity" "current" {}

# Get current AWS region
data "aws_region" "current" {}

# Get AWS partition (aws, aws-cn, aws-us-gov)
data "aws_partition" "current" {}

# -----------------------------------------------------------------------------
# S3 and Storage Data Sources
# -----------------------------------------------------------------------------

# Get the AWS S3 bucket policy for the current region
data "aws_iam_policy_document" "s3_bucket_policy" {
  statement {
    sid    = "DenyInsecureConnections"
    effect = "Deny"
    
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    
    actions = ["s3:*"]
    
    resources = [
      "arn:${data.aws_partition.current.partition}:s3:::${local.resource_names.s3_bucket}",
      "arn:${data.aws_partition.current.partition}:s3:::${local.resource_names.s3_bucket}/*"
    ]
    
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

# -----------------------------------------------------------------------------
# Instance and Compute Data Sources
# -----------------------------------------------------------------------------

# Get instance type details
data "aws_ec2_instance_type" "selected" {
  instance_type = var.instance_type
}

# Get EBS volume types available in the region
data "aws_ebs_default_kms_key" "current" {}

# -----------------------------------------------------------------------------
# Template Data Sources
# -----------------------------------------------------------------------------

# Render the user data script with variables
data "template_file" "user_data" {
  template = file("${path.module}/user_data.sh")
  
  vars = local.user_data_vars
}