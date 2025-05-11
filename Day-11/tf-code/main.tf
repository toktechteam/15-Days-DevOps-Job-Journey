provider "aws" {
  region  = var.region
  profile = var.profile
}

# Backend Configuration #

# terraform {
#   backend "s3" {
#     bucket         = "your-s3-bucket-name"
#     key            = "terraform-project/terraform.tfstate"
#     region         = var.region
#     dynamodb_table = "your-dynamodb-lock-table"
#     encrypt        = true
#   }
# }
#

terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-211224"
    key            = "devops/ec2/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-lock-table-new"
    encrypt        = true
  }
}

# Data #

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

## vpc, subnet ##
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Security Group Creation #
resource "aws_security_group" "dev_sg" {
  name        = "dev_sg"
  description = "Allow SSH & HTTP"

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


### Create Key Pair ##

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("~/.ssh/id_rsa.pub")  # Update this path to your public key
}


# Create Ec2 Instance with Default VPC
resource "aws_instance" "web" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = tolist(data.aws_subnets.default.ids)[0]
  vpc_security_group_ids = [aws_security_group.dev_sg.id]
  key_name               = var.key_name

  tags = {
    Name = "WebInstance"
  }
}