#!/bin/bash

# Update system packages
sudo yum update -y

# Install required dependencies for Amazon Linux 2023
sudo yum install -y curl-minimal wget git jq unzip tar java-17-amazon-corretto-headless

# Install Node.js (Amazon Linux 2023 version)
sudo yum install -y nodejs

# Install Docker (Amazon Linux 2023 version)
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# Install Trivy
LATEST=$(curl -s https://api.github.com/repos/aquasecurity/trivy/releases/latest | grep browser_download_url | grep "Linux-64bit.rpm\"" | cut -d '"' -f 4)
wget $LATEST
sudo rpm -ivh trivy_*_Linux-64bit.rpm

# Install SonarScanner
SONAR_SCANNER_VERSION="4.8.0.2856"
wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_SCANNER_VERSION}-linux.zip
unzip sonar-scanner-cli-${SONAR_SCANNER_VERSION}-linux.zip
sudo mv sonar-scanner-${SONAR_SCANNER_VERSION}-linux /opt/sonar-scanner
sudo ln -s /opt/sonar-scanner/bin/sonar-scanner /usr/local/bin/sonar-scanner
echo 'export PATH=$PATH:/opt/sonar-scanner/bin' | sudo tee -a /etc/profile.d/sonar-scanner.sh
source /etc/profile.d/sonar-scanner.sh
sonar-scanner -v || echo "SonarScanner installation may have issues"

# Create project directories
mkdir -p ~/devops-demo

# Create Docker Compose file with customized Jenkins image
cat > ~/devops-demo/Dockerfile.jenkins << 'EOF'
FROM jenkins/jenkins:lts

USER root

# Install Java 17
RUN apt-get update && \
    apt-get install -y openjdk-17-jdk && \
    update-java-alternatives -s java-1.17.0-openjdk-amd64

# Install Docker CLI using the recommended approach
RUN apt-get update && \
    apt-get -y install apt-transport-https ca-certificates curl gnupg lsb-release && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get -y install docker-ce-cli

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get install -y nodejs

# Install required tools
RUN apt-get install -y python3-pip git

# Install plugins using Jenkins CLI with correct flags
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt --verbose --skip-failed-plugins --latest

USER jenkins
EOF

# Create plugins.txt file for Jenkins
cat > ~/devops-demo/plugins.txt << 'EOF'
docker-workflow:latest
pipeline-utility-steps:latest
sonar:latest
nodejs:latest
git:latest
docker-plugin:latest
credentials:latest
workflow-aggregator:latest
docker-build-step:latest
blueocean:latest
EOF

# Create Docker Compose file
cat > ~/devops-demo/docker-compose.yml << 'EOF'
version: '3.8'

services:
  jenkins:
    build:
      context: .
      dockerfile: Dockerfile.jenkins
    privileged: true
    user: root
    ports:
      - "8081:8080"
      - "50000:50000"
    volumes:
      - jenkins_home:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock
      - /usr/local/bin/sonar-scanner:/usr/local/bin/sonar-scanner
    environment:
      - JAVA_OPTS=-Dhudson.model.DirectoryBrowserSupport.CSP=
    networks:
      - devops-network

  sonarqube:
    image: sonarqube:latest
    ports:
      - "9000:9000"
    environment:
      - SONAR_JDBC_URL=jdbc:postgresql://sonardb:5432/sonar
      - SONAR_JDBC_USERNAME=sonar
      - SONAR_JDBC_PASSWORD=sonar
    volumes:
      - sonarqube_data:/opt/sonarqube/data
      - sonarqube_extensions:/opt/sonarqube/extensions
      - sonarqube_logs:/opt/sonarqube/logs
    depends_on:
      - sonardb
    networks:
      - devops-network

  sonardb:
    image: postgres:13
    environment:
      - POSTGRES_USER=sonar
      - POSTGRES_PASSWORD=sonar
      - POSTGRES_DB=sonar
    volumes:
      - postgresql_data:/var/lib/postgresql/data
    networks:
      - devops-network

volumes:
  jenkins_home:
  sonarqube_data:
  sonarqube_extensions:
  sonarqube_logs:
  postgresql_data:

networks:
  devops-network:
    driver: bridge
EOF