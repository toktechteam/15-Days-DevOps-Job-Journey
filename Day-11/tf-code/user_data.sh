#!/bin/bash
# =============================================================================
# User Data Script for Day-11 Terraform Demo
# =============================================================================
# This script runs when the EC2 instance first boots up
# It installs basic tools and prepares the instance for DevOps demonstrations

# Log all output
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "=== Starting User Data Script ==="
echo "Environment: ${environment}"
echo "Timestamp: $(date)"

# Update the system
echo "=== Updating system packages ==="
yum update -y

# Install essential tools
echo "=== Installing essential tools ==="
yum install -y \
    git \
    wget \
    curl \
    unzip \
    htop \
    tree \
    vim \
    nano \
    jq \
    awscli

# Install Docker (for future use in upcoming days)
echo "=== Installing Docker ==="
yum install -y docker
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user

# Install Docker Compose (for future use)
echo "=== Installing Docker Compose ==="
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# Install Node.js (for our application)
echo "=== Installing Node.js ==="
curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
yum install -y nodejs

# Create a simple web server for testing
echo "=== Creating simple web server ==="
mkdir -p /home/ec2-user/demo-app
cat > /home/ec2-user/demo-app/server.js << 'EOF'
const http = require('http');
const os = require('os');

const server = http.createServer((req, res) => {
    const response = {
        message: 'Hello from Terraform-created EC2 instance!',
        environment: process.env.ENVIRONMENT || 'unknown',
        hostname: os.hostname(),
        timestamp: new Date().toISOString(),
        uptime: os.uptime(),
        platform: os.platform(),
        version: process.version
    };
    
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify(response, null, 2));
});

const PORT = 3000;
server.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
EOF

# Set environment variable
echo "export ENVIRONMENT=${environment}" >> /home/ec2-user/.bashrc

# Change ownership
chown -R ec2-user:ec2-user /home/ec2-user/demo-app

# Create systemd service for the demo app
cat > /etc/systemd/system/demo-app.service << EOF
[Unit]
Description=Demo Node.js Application
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/home/ec2-user/demo-app
ExecStart=/usr/bin/node server.js
Restart=on-failure
Environment=ENVIRONMENT=${environment}

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the demo app
systemctl daemon-reload
systemctl enable demo-app
systemctl start demo-app

# Install nginx as reverse proxy
echo "=== Installing and configuring Nginx ==="
yum install -y nginx

# Configure nginx to proxy to our Node.js app
cat > /etc/nginx/conf.d/demo-app.conf << 'EOF'
server {
    listen 80;
    server_name _;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
    
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
}
EOF

# Start nginx
systemctl start nginx
systemctl enable nginx

# Create a welcome message
cat > /home/ec2-user/README.md << EOF
# Day-11 Terraform Demo Instance

This EC2 instance was created by Terraform as part of the DevOps learning journey.

## What's Installed
- Docker and Docker Compose
- Node.js 18
- Nginx (reverse proxy)
- AWS CLI
- Common development tools

## Demo Application
A simple Node.js application is running on port 3000 and proxied through Nginx on port 80.

- Application: http://localhost:3000
- Web (via Nginx): http://localhost:80
- Health check: http://localhost/health

## Services
- demo-app.service: Node.js application
- nginx.service: Web server/reverse proxy
- docker.service: Docker daemon

## Commands to Try
\`\`\`bash
# Check service status
sudo systemctl status demo-app
sudo systemctl status nginx

# View logs
sudo journalctl -u demo-app -f
sudo tail -f /var/log/nginx/access.log

# Test the application
curl http://localhost
curl http://localhost/health

# Docker commands
docker --version
docker-compose --version
\`\`\`

Environment: ${environment}
Created: $(date)
EOF

chown ec2-user:ec2-user /home/ec2-user/README.md

# Final status check
echo "=== Final Status Check ==="
systemctl is-active docker
systemctl is-active nginx
systemctl is-active demo-app

echo "=== User Data Script Completed Successfully ==="
echo "Instance is ready for DevOps demonstrations!"
echo "Check /home/ec2-user/README.md for more information."