#!/bin/bash

echo "🚀 Day-09 DevOps Setup - Jenkins on Host + SonarQube in Container"
echo "=================================================================="

# Update system packages
echo "📦 Updating system packages..."
sudo yum update -y

# Install required dependencies
echo "📦 Installing core dependencies..."
sudo yum install -y curl-minimal wget git jq unzip tar java-17-amazon-corretto-headless nodejs npm

# Set JAVA_HOME properly
echo "☕ Setting up Java environment..."
export JAVA_HOME=/usr/lib/jvm/java-17-amazon-corretto.x86_64
echo 'export JAVA_HOME=/usr/lib/jvm/java-17-amazon-corretto.x86_64' | sudo tee -a /etc/profile
echo 'export PATH=$JAVA_HOME/bin:$PATH' | sudo tee -a /etc/profile
source /etc/profile

# Verify Java
echo "Java version: $(java -version 2>&1 | head -1)"
echo "JAVA_HOME: $JAVA_HOME"

# Install Docker
echo "🐳 Installing Docker..."
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user
sudo chmod 777 /var/run/docker.sock

# Install Docker Compose
echo "🐳 Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# Verify Docker installations
echo "Docker version: $(docker --version)"
echo "Docker Compose version: $(docker-compose --version)"

# Install Trivy
echo "🔒 Installing Trivy security scanner..."
LATEST=$(curl -s https://api.github.com/repos/aquasecurity/trivy/releases/latest | grep browser_download_url | grep "Linux-64bit.rpm" | cut -d '"' -f 4)
wget $LATEST
sudo rpm -ivh trivy_*_Linux-64bit.rpm

# Verify Trivy
echo "Trivy version: $(trivy --version | head -1)"

# Install SonarScanner
echo "📊 Installing SonarQube Scanner..."
SONAR_SCANNER_VERSION="4.8.0.2856"
wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_SCANNER_VERSION}-linux.zip
unzip sonar-scanner-cli-${SONAR_SCANNER_VERSION}-linux.zip
sudo mv sonar-scanner-${SONAR_SCANNER_VERSION}-linux /opt/sonar-scanner

# Configure SonarScanner to use Java 17
echo "⚙️ Configuring SonarScanner with Java 17..."
sudo tee /opt/sonar-scanner/bin/sonar-scanner << 'SONAR_EOF'
#!/bin/bash
export JAVA_HOME=/usr/lib/jvm/java-17-amazon-corretto.x86_64
export PATH=$JAVA_HOME/bin:$PATH
exec "$JAVA_HOME/bin/java" -Djava.awt.headless=true -cp /opt/sonar-scanner/lib/sonar-scanner-cli-4.8.0.2856.jar org.sonarsource.scanner.cli.Main "$@"
SONAR_EOF

sudo chmod +x /opt/sonar-scanner/bin/sonar-scanner
sudo ln -s /opt/sonar-scanner/bin/sonar-scanner /usr/local/bin/sonar-scanner

# Add SonarScanner to PATH with Java 17
echo 'export PATH=$PATH:/opt/sonar-scanner/bin' | sudo tee -a /etc/profile.d/sonar-scanner.sh
echo 'export SONAR_SCANNER_OPTS="-Djava.home=/usr/lib/jvm/java-17-amazon-corretto.x86_64"' | sudo tee -a /etc/profile.d/sonar-scanner.sh
source /etc/profile.d/sonar-scanner.sh

# Verify SonarScanner with correct Java
echo "SonarScanner version: $(sonar-scanner --version 2>&1 | head -1)"
echo "Java version used by SonarScanner: $(/usr/lib/jvm/java-17-amazon-corretto.x86_64/bin/java -version 2>&1 | head -1)"

# Install Jenkins
echo "🏗️ Installing Jenkins on EC2 host..."
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum install jenkins -y

# Configure Jenkins
echo "⚙️ Configuring Jenkins..."
echo "JAVA_HOME=/usr/lib/jvm/java-17-amazon-corretto.x86_64" | sudo tee -a /etc/sysconfig/jenkins
sudo sed -i 's/JENKINS_PORT="8080"/JENKINS_PORT="8081"/g' /etc/sysconfig/jenkins

# Start Jenkins
echo "🚀 Starting Jenkins..."
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Wait for Jenkins to initialize
echo "⏳ Waiting for Jenkins to initialize..."
sleep 45

# Create SonarQube setup
echo "📊 Setting up SonarQube with Docker..."
mkdir -p ~/devops-demo
cd ~/devops-demo

# Install MariaDB on EC2 host (Amazon Linux 2023)
echo "🗄️ Installing MariaDB on EC2 host..."
sudo dnf install -y mariadb105-server
sudo systemctl enable mariadb
sudo systemctl start mariadb

# Secure MariaDB installation
echo "⚙️ Configuring MariaDB..."
sudo mysql -e "
ALTER USER 'root'@'localhost' IDENTIFIED BY 'Root@123456';
CREATE DATABASE IF NOT EXISTS student_management;
USE student_management;
CREATE TABLE IF NOT EXISTS students (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    course VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT IGNORE INTO students (name, email, course) VALUES
('John Doe', 'john.doe@example.com', 'Computer Science'),
('Jane Smith', 'jane.smith@example.com', 'Information Technology'),
('Mike Johnson', 'mike.johnson@example.com', 'Software Engineering');
FLUSH PRIVILEGES;
"

echo "MariaDB setup complete. Root password: Root@123456"

# Create SonarQube setup
echo "📊 Setting up SonarQube with Docker..."
mkdir -p ~/devops-demo
cd ~/devops-demo

# Create docker-compose.yml for SonarQube
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  sonarqube:
    image: sonarqube:latest
    container_name: sonarqube
    restart: always
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
      - sonar-network

  sonardb:
    image: postgres:13
    container_name: sonardb
    restart: always
    environment:
      - POSTGRES_USER=sonar
      - POSTGRES_PASSWORD=sonar
      - POSTGRES_DB=sonar
    volumes:
      - postgresql_data:/var/lib/postgresql/data
    networks:
      - sonar-network

volumes:
  sonarqube_data:
  sonarqube_extensions:
  sonarqube_logs:
  postgresql_data:

networks:
  sonar-network:
    driver: bridge
EOF
version: '3.8'

services:
  sonarqube:
    image: sonarqube:latest
    container_name: sonarqube
    restart: always
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
      - sonar-network

  sonardb:
    image: postgres:13
    container_name: sonardb
    restart: always
    environment:
      - POSTGRES_USER=sonar
      - POSTGRES_PASSWORD=sonar
      - POSTGRES_DB=sonar
    volumes:
      - postgresql_data:/var/lib/postgresql/data
    networks:
      - sonar-network

volumes:
  sonarqube_data:
  sonarqube_extensions:
  sonarqube_logs:
  postgresql_data:

networks:
  sonar-network:
    driver: bridge
EOF

# Configure system for SonarQube
echo "⚙️ Configuring system for SonarQube..."
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Start SonarQube
echo "🚀 Starting SonarQube..."
docker-compose up -d

# Wait for services
echo "⏳ Waiting for SonarQube to start..."
sleep 60

# Get EC2 public IP
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

# Display Jenkins password
echo ""
echo "✅ SETUP COMPLETE!"
echo "==================="
echo ""
echo "🔑 Jenkins Initial Password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
echo ""
echo "🔗 Access URLs:"
echo "Jenkins: http://$PUBLIC_IP:8081"
echo "SonarQube: http://$PUBLIC_IP:9000 (admin/admin)"
echo ""
echo "📋 Jenkins Configuration Steps:"
echo "1. Access Jenkins URL above"
echo "2. Use initial password shown above"
echo "3. Install suggested plugins + 'SonarQube Scanner' plugin"
echo "4. Create admin user"
echo "5. Configure SonarQube integration:"
echo "   - Manage Jenkins → Configure System"
echo "   - Add SonarQube server:"
echo "     Name: SonarLocal"
echo "     Server URL: http://$PUBLIC_IP:9000"
echo "     Authentication: Create token in SonarQube first"
echo ""
echo "⚠️ IMPORTANT: Exit and re-login to apply docker group permissions"
echo "   exit"
echo "   ssh -i your-key.pem ec2-user@$PUBLIC_IP"
echo ""
echo "🎉 Ready for Day-09 CI Pipeline and Day-10 CD Pipeline!"