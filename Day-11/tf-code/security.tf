# =============================================================================
# SECURITY RESOURCES
# =============================================================================
# This file contains all security-related resources including security groups,
# key pairs, and access control configurations

# -----------------------------------------------------------------------------
# Key Pair for SSH Access
# -----------------------------------------------------------------------------

# Create a key pair for SSH access to EC2 instances
# Note: In production, use existing key pairs or AWS Systems Manager Session Manager
resource "aws_key_pair" "demo_key" {
  count = var.enable_ssh_access ? 1 : 0
  
  key_name   = local.resource_names.key_pair
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDH8... # Replace with your actual public key"
  
  tags = merge(local.security_tags, {
    Name = local.resource_names.key_pair
    Type = "access-key"
  })
}

# -----------------------------------------------------------------------------
# Security Group for Demo Instance
# -----------------------------------------------------------------------------

# Security group controlling network access to our demo instance
resource "aws_security_group" "demo_sg" {
  name_prefix = "${local.common_name}-sg-"
  description = "Security group for ${local.common_name} demo instances"
  vpc_id      = data.aws_vpc.default.id

  tags = merge(local.security_tags, {
    Name = local.resource_names.security_group
  })
  
  # Lifecycle rule to avoid dependency issues during updates
  lifecycle {
    create_before_destroy = true
  }
}

# -----------------------------------------------------------------------------
# Security Group Rules - Ingress (Inbound)
# -----------------------------------------------------------------------------

# SSH access rule (conditional based on variable)
resource "aws_security_group_rule" "ssh_ingress" {
  count = var.enable_ssh_access ? 1 : 0
  
  type              = "ingress"
  description       = "SSH access for administration"
  from_port         = local.ports.ssh
  to_port           = local.ports.ssh
  protocol          = "tcp"
  cidr_blocks       = [var.allowed_ssh_cidr]
  security_group_id = aws_security_group.demo_sg.id
}

# HTTP access rule
resource "aws_security_group_rule" "http_ingress" {
  type              = "ingress"
  description       = "HTTP access for web application"
  from_port         = local.ports.http
  to_port           = local.ports.http
  protocol          = "tcp"
  cidr_blocks       = [local.cidrs.anywhere]
  security_group_id = aws_security_group.demo_sg.id
}

# HTTPS access rule
resource "aws_security_group_rule" "https_ingress" {
  type              = "ingress"
  description       = "HTTPS access for secure web application"
  from_port         = local.ports.https
  to_port           = local.ports.https
  protocol          = "tcp"
  cidr_blocks       = [local.cidrs.anywhere]
  security_group_id = aws_security_group.demo_sg.id
}

# Application port access (for direct access to Node.js app)
resource "aws_security_group_rule" "app_ingress" {
  type              = "ingress"
  description       = "Direct access to application port"
  from_port         = local.ports.app
  to_port           = local.ports.app
  protocol          = "tcp"
  cidr_blocks       = [local.cidrs.anywhere]
  security_group_id = aws_security_group.demo_sg.id
}

# ICMP (ping) access for network troubleshooting
resource "aws_security_group_rule" "icmp_ingress" {
  type              = "ingress"
  description       = "ICMP for network troubleshooting"
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
  cidr_blocks       = [local.cidrs.anywhere]
  security_group_id = aws_security_group.demo_sg.id
}

# -----------------------------------------------------------------------------
# Security Group Rules - Egress (Outbound)
# -----------------------------------------------------------------------------

# Allow all outbound traffic (common pattern for web servers)
resource "aws_security_group_rule" "all_egress" {
  type              = "egress"
  description       = "Allow all outbound traffic"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [local.cidrs.anywhere]
  security_group_id = aws_security_group.demo_sg.id
}

# Alternative: Restricted egress rules (uncomment for production)
# # HTTP outbound for package downloads
# resource "aws_security_group_rule" "http_egress" {
#   type              = "egress"
#   description       = "HTTP outbound for package downloads"
#   from_port         = 80
#   to_port           = 80
#   protocol          = "tcp"
#   cidr_blocks       = ["0.0.0.0/0"]
#   security_group_id = aws_security_group.demo_sg.id
# }
# 
# # HTTPS outbound for secure downloads
# resource "aws_security_group_rule" "https_egress" {
#   type              = "egress"
#   description       = "HTTPS outbound for secure downloads"
#   from_port         = 443
#   to_port           = 443
#   protocol          = "tcp"
#   cidr_blocks       = ["0.0.0.0/0"]
#   security_group_id = aws_security_group.demo_sg.id
# }
# 
# # DNS outbound
# resource "aws_security_group_rule" "dns_egress" {
#   type              = "egress"
#   description       = "DNS resolution"
#   from_port         = 53
#   to_port           = 53
#   protocol          = "udp"
#   cidr_blocks       = ["0.0.0.0/0"]
#   security_group_id = aws_security_group.demo_sg.id
# }

# -----------------------------------------------------------------------------
# IAM Role for EC2 Instance (Optional)
# -----------------------------------------------------------------------------

# IAM role for EC2 instance to access AWS services
resource "aws_iam_role" "ec2_role" {
  count = local.is_production ? 1 : 0
  
  name = "${local.common_name}-ec2-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
  
  tags = merge(local.security_tags, {
    Name = "${local.common_name}-ec2-role"
    Type = "iam-role"
  })
}

# IAM instance profile for EC2
resource "aws_iam_instance_profile" "ec2_profile" {
  count = local.is_production ? 1 : 0
  
  name = "${local.common_name}-ec2-profile"
  role = aws_iam_role.ec2_role[0].name
  
  tags = merge(local.security_tags, {
    Name = "${local.common_name}-ec2-profile"
    Type = "iam-instance-profile"
  })
}

# Attach CloudWatch agent policy (for monitoring)
resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  count = local.is_production ? 1 : 0
  
  role       = aws_iam_role.ec2_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Attach SSM managed instance policy (for Session Manager)
resource "aws_iam_role_policy_attachment" "ssm_managed_instance" {
  count = local.is_production ? 1 : 0
  
  role       = aws_iam_role.ec2_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}