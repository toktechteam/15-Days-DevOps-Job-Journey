# =============================================================================
# STORAGE RESOURCES
# =============================================================================
# This file contains all storage-related resources including S3 buckets,
# EBS volumes, and storage configurations

# -----------------------------------------------------------------------------
# S3 Bucket for Demo
# -----------------------------------------------------------------------------

# Main S3 bucket for demonstrations
resource "aws_s3_bucket" "demo_bucket" {
  bucket = local.resource_names.s3_bucket
  
  tags = merge(local.storage_tags, {
    Name = local.resource_names.s3_bucket
    Type = "demo-bucket"
  })
}

# -----------------------------------------------------------------------------
# S3 Bucket Configuration
# -----------------------------------------------------------------------------

# Bucket versioning configuration
resource "aws_s3_bucket_versioning" "demo_bucket_versioning" {
  bucket = aws_s3_bucket.demo_bucket.id
  
  versioning_configuration {
    status = var.enable_s3_versioning ? "Enabled" : "Disabled"
  }
}

# Bucket encryption configuration
resource "aws_s3_bucket_server_side_encryption_configuration" "demo_bucket_encryption" {
  bucket = aws_s3_bucket.demo_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.s3_encryption_algorithm
    }
    
    bucket_key_enabled = true
  }
}

# Block all public access to the bucket
resource "aws_s3_bucket_public_access_block" "demo_bucket_pab" {
  bucket = aws_s3_bucket.demo_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Bucket lifecycle configuration
resource "aws_s3_bucket_lifecycle_configuration" "demo_bucket_lifecycle" {
  bucket = aws_s3_bucket.demo_bucket.id

  rule {
    id     = "demo_lifecycle_rule"
    status = "Enabled"

    # Transition to IA after 30 days
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    # Transition to Glacier after 90 days
    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    # Delete old versions after 365 days
    noncurrent_version_expiration {
      noncurrent_days = 365
    }

    # Delete incomplete multipart uploads after 7 days
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# Bucket notification configuration (optional)
resource "aws_s3_bucket_notification" "demo_bucket_notification" {
  count  = local.is_production ? 1 : 0
  bucket = aws_s3_bucket.demo_bucket.id

  # CloudWatch Events
  cloudwatchconfiguration {
    cloudwatch_configuration {
      events = ["s3:ObjectCreated:*"]
    }
  }
}

# -----------------------------------------------------------------------------
# S3 Bucket Policy
# -----------------------------------------------------------------------------

# Bucket policy to deny insecure connections
resource "aws_s3_bucket_policy" "demo_bucket_policy" {
  bucket = aws_s3_bucket.demo_bucket.id
  policy = data.aws_iam_policy_document.s3_bucket_policy.json
}

# -----------------------------------------------------------------------------
# S3 Objects for Demonstration
# -----------------------------------------------------------------------------

# Create demo files in the S3 bucket
resource "aws_s3_object" "demo_files" {
  count = var.create_demo_files
  
  bucket       = aws_s3_bucket.demo_bucket.bucket
  key          = "demo-files/demo-file-${count.index + 1}.txt"
  content      = "This is demo file number ${count.index + 1} created by Terraform\nEnvironment: ${var.environment}\nCreated: ${local.timestamp}"
  content_type = "text/plain"
  
  # Server-side encryption
  server_side_encryption = var.s3_encryption_algorithm
  
  tags = merge(local.storage_tags, {
    Name = "demo-file-${count.index + 1}"
    Type = "demo-object"
  })
}

# Upload a sample configuration file
resource "aws_s3_object" "config_file" {
  bucket       = aws_s3_bucket.demo_bucket.bucket
  key          = "config/app-config.json"
  content_type = "application/json"
  
  content = jsonencode({
    environment = var.environment
    app_port   = var.app_port
    region     = var.aws_region
    features = {
      monitoring = var.enable_detailed_monitoring
      ssh_access = var.enable_ssh_access
      versioning = var.enable_s3_versioning
    }
    metadata = {
      created_by = "terraform"
      project    = var.project_name
      timestamp  = local.timestamp
    }
  })
  
  server_side_encryption = var.s3_encryption_algorithm
  
  tags = merge(local.storage_tags, {
    Name = "app-config"
    Type = "configuration-file"
  })
}

# -----------------------------------------------------------------------------
# Additional EBS Volume (Optional)
# -----------------------------------------------------------------------------

# Additional EBS volume for data storage
resource "aws_ebs_volume" "demo_data_volume" {
  count = var.environment == "prod" ? 1 : 0
  
  availability_zone = aws_instance.demo_instance.availability_zone
  size              = 50
  type              = "gp3"
  encrypted         = true
  
  tags = merge(local.storage_tags, {
    Name = "${local.resource_names.instance}-data-volume"
    Type = "data-volume"
  })
}

# Attach the additional EBS volume to the instance
resource "aws_volume_attachment" "demo_data_attachment" {
  count = var.environment == "prod" ? 1 : 0
  
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.demo_data_volume[0].id
  instance_id = aws_instance.demo_instance.id
}

# -----------------------------------------------------------------------------
# EBS Snapshot (Optional)
# -----------------------------------------------------------------------------

# Create snapshot of the root volume for backup
resource "aws_ebs_snapshot" "demo_snapshot" {
  count = local.is_production ? 1 : 0
  
  volume_id   = aws_instance.demo_instance.root_block_device[0].volume_id
  description = "Snapshot of ${local.resource_names.instance} root volume"
  
  tags = merge(local.storage_tags, {
    Name = "${local.resource_names.instance}-snapshot"
    Type = "ebs-snapshot"
  })
}

# -----------------------------------------------------------------------------
# S3 Bucket for Logs (Optional)
# -----------------------------------------------------------------------------

# Separate bucket for application logs
resource "aws_s3_bucket" "logs_bucket" {
  count = local.is_production ? 1 : 0
  
  bucket = "${local.common_name}-logs-${local.unique_suffix}"
  
  tags = merge(local.storage_tags, {
    Name = "${local.common_name}-logs-bucket"
    Type = "logs-bucket"
  })
}

# Logs bucket versioning
resource "aws_s3_bucket_versioning" "logs_bucket_versioning" {
  count = local.is_production ? 1 : 0
  
  bucket = aws_s3_bucket.logs_bucket[0].id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# Logs bucket encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "logs_bucket_encryption" {
  count = local.is_production ? 1 : 0
  
  bucket = aws_s3_bucket.logs_bucket[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Logs bucket lifecycle (shorter retention for logs)
resource "aws_s3_bucket_lifecycle_configuration" "logs_bucket_lifecycle" {
  count = local.is_production ? 1 : 0
  
  bucket = aws_s3_bucket.logs_bucket[0].id

  rule {
    id     = "logs_lifecycle_rule"
    status = "Enabled"

    # Delete logs after 90 days
    expiration {
      days = 90
    }

    # Delete old versions after 30 days
    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}