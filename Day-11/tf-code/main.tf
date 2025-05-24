# =============================================================================
# Day-11: Simple Terraform Configuration for Beginners
# =============================================================================

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Get the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Get default VPC
data "aws_vpc" "default" {
  default = true
}

# Get default subnets
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Create Security Group
resource "aws_security_group" "demo_sg" {
  name_prefix = "${var.environment}-demo-sg-"
  description = "Security group for demo instance"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-demo-sg"
    Environment = var.environment
  }
}

# Create Key Pair
resource "aws_key_pair" "demo_key" {
  key_name   = "${var.environment}-demo-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQColThoFfGHRhIy7kGjmThQR4GVGlxe6cNWWK6voSOylKDked3LVkUq9+GM7K+7uN5ccNgFlr/1veQReXI3X8ZFTn4+h0BaKlXNYByzy9FLGhX1Ewiz+uqmSA2GcROoP3wFDiLhgoL4Tpumj0gzUo/9NaCTaylSGtubDRPTMxuLUdCrrPj3WZnGi1r29UC6gPxhKryvjoHR5jItoKRu34CV/dvV9K4uCgxCX25EnSzq3GmE3Qz3dHd1pSF8XFpm1Ix8Sv1DX2TM7pJenH+8wBlCM5yWaiMD1pjyK9hehJeXs5kzR3Cb05pbmKv4mzdTfJ2SDVwQLsCAAp7ipEbh5UvGu423isJ/XDrpQ8IgjpszHnwpsrUT1ZddUJ8eKZv+lexjL9YeB+9cm+fZML0kNbQYHlfXj6CngLcqecpuaKPy38tyxp8ZFRMdlEq4hSEy2x+hPtZXBeQ9HYsZ5lnGsbmSjt0w3ovQlIoEKOv0Wwc9sz3bnbkwyWnvnTYWqh5dkHE= ec2-user@ip-172-31-33-218.us-west-2.compute.internal" # Replace with your public key

  tags = {
    Name        = "${var.environment}-demo-key"
    Environment = var.environment
  }
}

# Create EC2 Instance
resource "aws_instance" "demo_instance" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.demo_key.key_name
  vpc_security_group_ids = [aws_security_group.demo_sg.id]
  subnet_id              = tolist(data.aws_subnets.default.ids)[0]

  user_data = file("user_data.sh")

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
  }

  tags = {
    Name        = "${var.environment}-demo-instance"
    Environment = var.environment
  }
}

####### S3 bucket code ########

# Create S3 Bucket
resource "aws_s3_bucket" "demo_bucket" {
  bucket = "${var.environment}-terraform-demo-bucket-${random_id.bucket_suffix.hex}"

  tags = {
    Name        = "${var.environment}-demo-bucket"
    Environment = var.environment
  }
}

# Random ID for unique bucket naming
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "demo_bucket_versioning" {
  bucket = aws_s3_bucket.demo_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "demo_bucket_encryption" {
  bucket = aws_s3_bucket.demo_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access to S3 bucket
resource "aws_s3_bucket_public_access_block" "demo_bucket_pab" {
  bucket = aws_s3_bucket.demo_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Create demo file in S3 bucket
resource "aws_s3_object" "demo_file" {
  bucket  = aws_s3_bucket.demo_bucket.bucket
  key     = "demo.txt"
  content = "Hello from Terraform! Environment: ${var.environment}"

  tags = {
    Name        = "demo-file"
    Environment = var.environment
  }
}