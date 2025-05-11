#!/bin/bash

# DevOps Tools Setup Script for Amazon Linux 2023
# Installs: Docker, Docker Compose, Jenkins, NodeJS, Trivy, SonarQube, and Sonar Scanner

echo "===== Starting DevOps Tools Setup ====="

# Function to print section headers
print_section() {
    echo ""
    echo "===== $1 ====="
    echo ""
}

# Function to check if command succeeded
check_status() {
    if [ $? -eq 0 ]; then
        echo "✅ $1 successful"
    else
        echo "❌ $1 failed"
        exit 1
    fi
}

# Update system packages
print_section "Updating System Packages"
sudo dnf update -y
check_status "System update"

# Install Docker
print_section "Installing Docker"
sudo dnf install docker -y
check_status "Docker installation"

# Start and enable Docker service
sudo systemctl start docker
sudo systemctl enable docker
check_status "Docker service setup"

# Add user to docker group
sudo usermod -aG docker ec2-user
sudo usermod -aG docker jenkins 2>/dev/null || true # May fail if Jenkins not yet installed
sudo chmod 777 /var/run/docker.sock
check_status "Docker permissions setup"

# Install Docker Compose
print_section "Installing Docker Compose"
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
check_status "Docker Compose installation"
docker-compose --version

# Install Java for Jenkins
print_section "Installing Java"
sudo dnf install java-17-amazon-corretto -y
check_status "Java installation"
java -version

# Install Jenkins
print_section "Installing Jenkins"
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
check_status "Jenkins repo setup"
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
check_status "Jenkins key import"
sudo dnf install jenkins -y
check_status "Jenkins installation"

# Start and enable Jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins
check_status "Jenkins service setup"
echo "Jenkins status:"
sudo systemctl status jenkins

# Restart Jenkins after Docker permission changes
sudo systemctl restart jenkins
check_status "Jenkins restart"

# Install NodeJS 18.x
print_section "Installing NodeJS"
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
check_status "NodeJS repo setup"
sudo yum install -y nodejs
check_status "NodeJS installation"
node --version

# Install Trivy
print_section "Installing Trivy"
TRIVY_VERSION="trivy_0.61.1_Linux-64bit.rpm"
wget "https://github.com/aquasecurity/trivy/releases/download/v0.61.1/${TRIVY_VERSION}"
check_status "Trivy download"
sudo rpm -ivh ${TRIVY_VERSION}
check_status "Trivy installation"
rm -f ${TRIVY_VERSION}
trivy --version

# Setup SonarQube with Docker Compose
print_section "Setting up SonarQube"
cat <<EOF > docker-compose-sonar.yml
version: '3'
services:
  sonarqube:
    image: sonarqube:community
    ports:
      - "9000:9000"
    environment:
      - SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true
    volumes:
      - sonar_data:/opt/sonarqube/data
      - sonar_extensions:/opt/sonarqube/extensions
volumes:
  sonar_data:
  sonar_extensions:
EOF
check_status "SonarQube docker-compose file creation"

# Start SonarQube
docker-compose -f docker-compose-sonar.yml up -d
check_status "SonarQube startup"

# Install Sonar Scanner
print_section "Installing Sonar Scanner"
cd /opt
sudo wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip
check_status "Sonar Scanner download"
sudo unzip -o sonar-scanner-cli-*.zip
check_status "Sonar Scanner unzip"

# Clean up and create sonar-scanner directory properly
if [ -d "/opt/sonar-scanner" ]; then
    echo "Removing existing sonar-scanner directory..."
    sudo rm -rf /opt/sonar-scanner
fi

# Get the exact name of the extracted directory
SCANNER_DIR=$(ls -d sonar-scanner-* | head -1)
echo "Found scanner directory: $SCANNER_DIR"

# Rename the directory to sonar-scanner
sudo mv "$SCANNER_DIR" sonar-scanner
check_status "Renaming sonar-scanner directory"

# Create the symbolic link
sudo rm -f /usr/bin/sonar-scanner 2>/dev/null || true
sudo ln -s /opt/sonar-scanner/bin/sonar-scanner /usr/bin/sonar-scanner
check_status "Creating sonar-scanner symlink"

# Export path for immediate use in this script
export PATH=$PATH:/opt/sonar-scanner/bin
echo "Verifying Sonar Scanner installation:"
which sonar-scanner || echo "Command not found. Will try running with full path."
/opt/sonar-scanner/bin/sonar-scanner --version || echo "Error running sonar-scanner command"

# Add sonar-scanner to PATH permanently for all users
sudo bash -c 'echo "export PATH=\$PATH:/opt/sonar-scanner/bin" > /etc/profile.d/sonar-scanner.sh'
sudo chmod +x /etc/profile.d/sonar-scanner.sh
check_status "Setting up Sonar Scanner path"

# Print Jenkins initial admin password
print_section "Jenkins Initial Admin Password"
echo "Your Jenkins initial admin password is:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
echo ""

# Print summary of installed tools
print_section "Installation Summary"
echo "✅ Docker $(docker --version | awk '{print $3}' | sed 's/,//')"
echo "✅ Docker Compose $(docker-compose --version | awk '{print $3}' | sed 's/,//')"
echo "✅ Jenkins $(java -jar /usr/lib/jenkins/jenkins.war --version 2>/dev/null || echo 'installed')"
echo "✅ Java $(java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}')"
echo "✅ NodeJS $(node -v)"
echo "✅ Trivy $(trivy --version 2>&1 | head -n 1 | awk '{print $2}')"
echo "✅ SonarQube (running in Docker on port 9000)"
echo "✅ Sonar Scanner $(sonar-scanner --version 2>&1 | head -n 1 | awk '{print $2}')"

echo ""
echo "===== Setup Complete ====="
echo ""
echo "Access points:"
echo "- Jenkins: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8080"
echo "- SonarQube: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):9000"
echo ""
echo "Make sure your security groups allow traffic on ports 8080 and 9000"
echo ""
echo "Log out and log back in for Docker group permissions to take effect."