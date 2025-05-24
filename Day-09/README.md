# 🚀 Day-09: Complete DevOps CI/CD Pipeline with Jenkins, SonarQube & Docker

> **Learning Objective**: Master the fundamentals of DevOps by building a production-ready CI/CD pipeline that includes automated testing, code quality analysis, security scanning, and containerized deployments.

## 🎯 What You Will Achieve

By the end of this Day-09 demo, you will have hands-on experience with:

- **CI/CD Pipeline Development**: Build a complete Jenkins pipeline with multiple stages
- **Code Quality Management**: Integrate SonarQube for static code analysis and quality gates
- **Security Integration**: Implement Trivy for container vulnerability scanning
- **Containerization**: Docker image building with proper versioning and tagging
- **Infrastructure as Code**: Container orchestration using Docker Compose
- **DevOps Best Practices**: Automated testing, reporting, and artifact management

### 🏆 Real-World Skills You'll Learn

1. **Jenkins Pipeline as Code**: Declarative pipelines with proper error handling
2. **Quality Gates**: Automated code quality checks that prevent bad code from reaching production
3. **Security Scanning**: Container vulnerability assessment in CI/CD workflows
4. **Docker Best Practices**: Multi-stage builds, proper tagging, and image optimization
5. **Environment Management**: Development vs production configurations
6. **Monitoring & Reporting**: Test coverage reports, quality metrics, and build artifacts

---

## 💻 Infrastructure Requirements

### Recommended EC2 Instance Configuration

| Component | Requirement | Reasoning |
|-----------|-------------|-----------|
| **Instance Type** | `t3a.xlarge` | Required for Jenkins on host + SonarQube container |
| **vCPUs** | 4 | Sufficient for parallel pipeline execution |
| **Memory** | 16GB RAM | Required for Jenkins, SonarQube, and Docker operations |
| **Storage** | 30GB EBS gp3 | Adequate for Docker images and build artifacts |
| **Network** | Enhanced networking | Better throughput for image pulls/pushes |

### 💰 Cost Analysis (ap-south-1 region)

- **Hourly Cost**: ~₹18.00/hour (~$0.216/hour)
- **Daily Cost**: ~₹432/day for 24-hour usage
- **Educational Cost**: ~₹108/day for 6-hour learning sessions

### Required Ports

| Port | Service | Purpose |
|------|---------|---------|
| 22 | SSH | Server management |
| 8081 | Jenkins | CI/CD dashboard |
| 9000 | SonarQube | Code quality analysis |
| 3306 | MySQL | Database server |
| 3000-3002 | Backend APIs | Application backend services |
| 8080, 8082-8083 | Frontend Apps | Application frontend services |

---

## 🏗️ Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Developer     │    │   Jenkins       │    │   Docker Hub    │
│                 │───▶│   (EC2 Host)    │───▶│   Registry      │
│   Git Push      │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │
                              ▼
                       ┌─────────────────┐
                       │   SonarQube     │
                       │   (Container)   │
                       └─────────────────┘
                              │
                              ▼
                       ┌─────────────────┐
                       │   Trivy         │
                       │   (EC2 Host)    │
                       └─────────────────┘
```

---

## 🛠️ Quick Setup Options

### Option 1: Automated Setup (Recommended)

Use our pre-configured script for instant setup:

```bash
# Download and run the automated setup script
wget https://raw.githubusercontent.com/toktechteam/15-Days-DevOps-Job-Journey/main/Day-09/setup_script.sh
chmod +x setup_script.sh
./setup_script.sh
```

The `setup_script.sh` script automatically:
- Installs all required dependencies (Java 17, Docker, Node.js, etc.)
- Installs Jenkins directly on EC2 host
- Configures SonarQube with PostgreSQL backend in containers
- Installs Trivy for security scanning on host
- Sets up proper networking for Jenkins-SonarQube communication

### Option 2: Manual Setup (For Learning Each Step)

Follow the step-by-step instructions below to understand each component.

---

## 📋 Manual Setup Instructions

### Step 1: Launch EC2 Instance

| Setting | Value |
|---------|-------|
| **Name** | devops-day09-demo |
| **AMI** | Amazon Linux 2023 (ami-0953476d60561c955) |
| **Instance Type** | t3a.xlarge |
| **Key Pair** | Create new keypair and download .pem file |
| **Security Group** | Allow SSH (22), HTTP (80), Custom TCP (8081, 9000) |

Connect to your instance:
```bash
chmod 400 your-key.pem
ssh -i your-key.pem ec2-user@<EC2-PUBLIC-IP>
```

### Step 2: Install Core Dependencies

```bash
# Update system
sudo yum update -y

# Install essential tools
sudo yum install -y curl-minimal wget git jq unzip tar

# Install Java 17 (Required for Jenkins and SonarQube)
sudo yum install -y java-17-amazon-corretto-headless

# Install Node.js (Required for application builds)
sudo yum install -y nodejs npm

# Verify installations
java -version
node --version
npm --version
```

### Step 3: Install Docker & Docker Compose

```bash
# Install Docker
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user
sudo chmod 777 /var/run/docker.sock

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# Verify installation
docker --version
docker-compose --version

# Important: Re-login to apply docker group permissions
exit
# SSH back in
```

### Step 4: Install Jenkins on EC2 Host

```bash
# Add Jenkins repository
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

# Install Jenkins
sudo yum install jenkins -y

# Configure Jenkins to use Java 17
echo 'JAVA_HOME=/usr/lib/jvm/java-17-amazon-corretto.x86_64' | sudo tee -a /etc/sysconfig/jenkins

# Set Jenkins to run on port 8081
sudo sed -i 's/JENKINS_PORT="8080"/JENKINS_PORT="8081"/g' /etc/sysconfig/jenkins

# Start and enable Jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Get Jenkins initial password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

### Step 5: Install Security Scanning Tools

```bash
# Install Trivy for container vulnerability scanning
LATEST=$(curl -s https://api.github.com/repos/aquasecurity/trivy/releases/latest | grep browser_download_url | grep "Linux-64bit.rpm" | cut -d '"' -f 4)
wget $LATEST
sudo rpm -ivh trivy_*_Linux-64bit.rpm

# Verify Trivy installation
trivy --version
```

### Step 6: Install SonarQube Scanner

```bash
# Install SonarScanner
SONAR_SCANNER_VERSION="4.8.0.2856"
wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_SCANNER_VERSION}-linux.zip
unzip sonar-scanner-cli-${SONAR_SCANNER_VERSION}-linux.zip
sudo mv sonar-scanner-${SONAR_SCANNER_VERSION}-linux /opt/sonar-scanner
sudo ln -s /opt/sonar-scanner/bin/sonar-scanner /usr/local/bin/sonar-scanner

# Add to system PATH
echo 'export PATH=$PATH:/opt/sonar-scanner/bin' | sudo tee -a /etc/profile.d/sonar-scanner.sh
source /etc/profile.d/sonar-scanner.sh

# Verify installation
sonar-scanner --version
```

### Step 7: Deploy SonarQube with Docker Compose

```bash
# Create project directory
mkdir -p ~/devops-demo
cd ~/devops-demo

# Create Docker Compose file for SonarQube
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  sonarqube:
    image: sonarqube:latest
    network_mode: "host"
    environment:
      - SONAR_WEB_PORT=9000
      - SONAR_JDBC_URL=jdbc:postgresql://localhost:5432/sonar
      - SONAR_JDBC_USERNAME=sonar
      - SONAR_JDBC_PASSWORD=sonar
    volumes:
      - sonarqube_data:/opt/sonarqube/data
      - sonarqube_extensions:/opt/sonarqube/extensions
      - sonarqube_logs:/opt/sonarqube/logs
    depends_on:
      - sonardb

  sonardb:
    image: postgres:13
    network_mode: "host"
    environment:
      - POSTGRES_USER=sonar
      - POSTGRES_PASSWORD=sonar
      - POSTGRES_DB=sonar
      - POSTGRES_PORT=5432
    volumes:
      - postgresql_data:/var/lib/postgresql/data

volumes:
  sonarqube_data:
  sonarqube_extensions:
  sonarqube_logs:
  postgresql_data:
EOF

# Configure system for SonarQube (ElasticSearch requirement)
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Start SonarQube
docker-compose up -d

# Monitor startup progress
docker-compose logs -f
```

---

## 🔧 Post-Installation Configuration

### 1. Access Jenkins (Port 8081)

Navigate to `http://<EC2-PUBLIC-IP>:8081` and complete setup:
- Use the initial admin password from earlier step
- Install suggested plugins
- **Additionally install these required plugins**:
    - **SonarQube Scanner** - For code quality analysis
    - **HTML Publisher** - For publishing test coverage reports
    - **Docker Pipeline** - For Docker operations in pipeline
- Create admin user
- Configure Jenkins URL

### 2. Access SonarQube (Port 9000)

Navigate to `http://<EC2-PUBLIC-IP>:9000`
- Default credentials: `admin/admin`
- You'll be prompted to change password on first login
- Create a new project: "student-backend"
- Generate authentication token for Jenkins integration

### 3. Configure Jenkins-SonarQube Integration

In Jenkins Dashboard:
1. **Manage Jenkins** → **Configure System**
2. Find **SonarQube servers** section
3. Add SonarQube server:
    - Name: `SonarLocal`
    - Server URL: `http://localhost:9000`
    - Authentication: Add credentials (Secret text) with SonarQube token
    - Credential ID: `sonar-token`

### 4. Setup Docker Hub Credentials

In Jenkins:
1. **Manage Jenkins** → **Manage Credentials**
2. Add **Username with password**:
    - ID: `docker-hub-creds`
    - Username: Your Docker Hub username
    - Password: Your Docker Hub password/token

### 5. Setup GitHub Credentials

In Jenkins:
1. **Manage Jenkins** → **Manage Credentials**
2. Add **Username with password**:
    - ID: `github_cred`
    - Username: Your GitHub username
    - Password: Your GitHub Personal Access Token

---

## 🚀 Running Your First Pipeline

### 1. Create New Pipeline Job

1. Click **New Item** → **Pipeline**
2. Name: `student-app-pipeline`
3. In **Pipeline** section, choose **Pipeline script from SCM**
4. Set SCM to **Git**
5. Repository URL: `https://github.com/toktechteam/15-Days-DevOps-Job-Journey.git`
6. Credentials: Select `github_cred`
7. Branch: `*/main`
8. Script Path: `Day-09/Jenkinsfile`

### 2. Pipeline Stages Explanation

Our pipeline includes these educational stages:

1. **Checkout**: Retrieves code from Git with commit tracking
2. **Install Dependencies**: NPM package installation with caching
3. **Run Tests**: Automated testing with coverage reporting
4. **SonarQube Analysis**: Code quality analysis and reporting
5. **Build & Scan Images**: Docker image creation and security scanning
6. **Push to Registry**: Automated deployment to Docker Hub

### 3. Understanding Build Artifacts

Each successful build creates:
- **Docker Images**: Tagged with `build-number-commit-sha`
- **Test Reports**: Code coverage and test results
- **Quality Reports**: SonarQube analysis results
- **Security Reports**: Trivy vulnerability scans

---

## 📊 Monitoring & Reporting

### Jenkins Build Reports
- **Test Results**: Junit test reports with pass/fail status
- **Code Coverage**: HTML reports showing code coverage percentages
- **Build History**: Track build success/failure trends

### SonarQube Quality Dashboard
- **Code Smells**: Design issues and maintainability problems
- **Bugs**: Potential runtime errors
- **Security Vulnerabilities**: Security hotspots and issues
- **Coverage**: Test coverage analysis
- **Duplications**: Code duplication analysis

### Trivy Security Reports
- **CVE Detection**: Known vulnerabilities in dependencies
- **Severity Classification**: Critical, High, Medium, Low
- **SBOM Generation**: Software Bill of Materials

---

## 🔍 Troubleshooting Guide

### Common Issues & Solutions

**Jenkins Won't Start**
```bash
# Check Jenkins status
sudo systemctl status jenkins

# Check Jenkins logs
sudo journalctl -u jenkins -f

# Restart Jenkins
sudo systemctl restart jenkins
```

**SonarQube Connection Issues**
```bash
# Check SonarQube container logs
cd ~/devops-demo
docker-compose logs sonarqube

# Test connection from Jenkins host
curl http://localhost:9000

# Restart SonarQube
docker-compose restart sonarqube
```

**Docker Permission Errors**
```bash
# Ensure user is in docker group
groups $USER

# If docker group missing, add and re-login
sudo usermod -aG docker $USER
exit
# SSH back in
```

**Pipeline Fails on Image Scan**
```bash
# Test Trivy installation
trivy image alpine:latest

# Check if Jenkins can access Trivy
sudo -u jenkins trivy --version
```

---

## 🌟 Best Practices Learned

### 1. Pipeline Design
- **Fail Fast**: Run quick tests first, expensive operations last
- **Parallel Execution**: Run independent tasks concurrently
- **Proper Error Handling**: Use `catchError` for non-critical failures

### 2. Security
- **Credential Management**: Never hardcode credentials in pipelines
- **Image Scanning**: Always scan images before deployment
- **Quality Gates**: Enforce quality standards automatically

### 3. Monitoring
- **Build Metrics**: Track build duration and success rates
- **Quality Trends**: Monitor code quality over time
- **Resource Usage**: Monitor container resource consumption

---

## 🔗 Additional Resources

- [Jenkins Pipeline Documentation](https://www.jenkins.io/doc/book/pipeline/)
- [SonarQube Quality Gates](https://docs.sonarqube.org/latest/user-guide/quality-gates/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Trivy Documentation](https://aquasecurity.github.io/trivy/)

---

## 📝 Next Steps

After completing Day-09, you'll be ready for **Day-10** where you'll build deployment pipelines using the same Jenkins setup to deploy your containerized applications to different environments.

**Day-10 will use this existing Jenkins installation - no additional setup required!**

---

**🎉 Congratulations!** You've successfully built a production-ready CI/CD pipeline with Jenkins on EC2 host and SonarQube in containers. This foundation will serve you well for Day-10 deployment pipelines and real-world scenarios.