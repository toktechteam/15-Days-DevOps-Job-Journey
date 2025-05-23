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
| **Instance Type** | `t3a.large` | Cost-effective with burstable CPU for CI/CD workloads |
| **vCPUs** | 2 | Sufficient for parallel pipeline execution |
| **Memory** | 8GB RAM | Required for SonarQube, Jenkins, and Docker operations |
| **Storage** | 30GB EBS gp3 | Adequate for Docker images and build artifacts |
| **Network** | Enhanced networking | Better throughput for image pulls/pushes |

### 💰 Cost Analysis (ap-south-1 region)

- **Hourly Cost**: ~₹9.00/hour (~$0.108/hour)
- **Daily Cost**: ~₹216/day for 24-hour usage
- **Educational Cost**: ~₹54/day for 6-hour learning sessions

### Required Ports

| Port | Service | Purpose |
|------|---------|---------|
| 22 | SSH | Server management |
| 8081 | Jenkins | CI/CD dashboard |
| 9000 | SonarQube | Code quality analysis |
| 80/443 | HTTP/HTTPS | Application access |

---

## 🏗️ Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Developer     │    │   Jenkins       │    │   Docker Hub    │
│                 │───▶│   Pipeline      │───▶│   Registry      │
│   Git Push      │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │
                              ▼
                       ┌─────────────────┐
                       │   SonarQube     │
                       │   Quality Gate  │
                       └─────────────────┘
                              │
                              ▼
                       ┌─────────────────┐
                       │   Trivy         │
                       │   Security Scan │
                       └─────────────────┘
```

---

## 🛠️ Quick Setup Options

### Option 1: Automated Setup (Recommended for Beginners)

Use our pre-configured script for instant setup:

```bash
# Download and run the automated setup script
wget https://raw.githubusercontent.com/toktechteam/15-Days-DevOps-Job-Journey/main/Day-09/setup.sh
chmod +x setup.sh
./setup.sh
```

The `setup.sh` script automatically:
- Installs all required dependencies (Java 17, Docker, Node.js, etc.)
- Sets up Jenkins with pre-configured plugins
- Configures SonarQube with PostgreSQL backend
- Installs Trivy for security scanning
- Creates optimized Docker Compose environment

### Option 2: Manual Setup (For Learning Each Step)

Follow the step-by-step instructions below to understand each component.

---

## 📋 Manual Setup Instructions

### Step 1: Launch EC2 Instance

| Setting | Value |
|---------|-------|
| **Name** | devops-day09-demo |
| **AMI** | Amazon Linux 2023 (ami-0953476d60561c955) |
| **Instance Type** | t3a.large |
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


# Install Java 17 (Required for SonarQube compatibility)
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

### Step 4: Install Security Scanning Tools

```bash
# Install Trivy for container vulnerability scanning
LATEST=$(curl -s https://api.github.com/repos/aquasecurity/trivy/releases/latest | grep browser_download_url | grep "Linux-64bit.rpm" | cut -d '"' -f 4)
wget $LATEST
sudo rpm -ivh trivy_*_Linux-64bit.rpm

# Verify Trivy installation
trivy --version
```

### Step 5: Install SonarQube Scanner

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

### Step 6: Deploy Jenkins & SonarQube with Docker Compose

```bash
# Create project directory
mkdir -p ~/devops-demo
cd ~/devops-demo

# The setup.sh script creates optimized Docker files
# For manual setup, use the configurations from our repository
git clone https://github.com/toktechteam/15-Days-DevOps-Job-Journey.git
cp 15-Days-DevOps-Job-Journey/Day-09/docker-compose.yml .
cp 15-Days-DevOps-Job-Journey/Day-09/Dockerfile.jenkins .
cp 15-Days-DevOps-Job-Journey/Day-09/plugins.txt .

# Configure system for SonarQube (ElasticSearch requirement)
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Build and start services
docker-compose build
docker-compose up -d

# Monitor startup progress
docker-compose logs -f
```

---

## 🔧 Post-Installation Configuration

### 1. Access Jenkins (Port 8081)

```bash
# Get Jenkins initial admin password
docker-compose exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

Navigate to `http://<EC2-PUBLIC-IP>:8081` and complete setup:
- Install suggested plugins
- Create admin user
- Configure Jenkins URL
- Install plugin `Cobertura`

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
   - Server URL: `http://sonarqube:9000`
   - Authentication: Use token from SonarQube
   - Create cred. for sonar auth name it `sonar-token`
   - Use the same token which is created in sonar

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
6. Branch: `*/main`
7. Script Path: `Day-09/Jenkinsfile`

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

## 🎓 Learning Exercises

### Exercise 1: Pipeline Customization
Modify the Jenkinsfile to add a new stage that runs ESLint for code style checking.

### Exercise 2: Quality Gate Configuration
Configure SonarQube quality gates to fail builds if code coverage drops below 80%.

### Exercise 3: Multi-Environment Deployment
Extend the pipeline to deploy to staging and production environments with approval gates.

### Exercise 4: Notification Integration
Add Slack or email notifications for build success/failure.

---

## 🔍 Troubleshooting Guide

### Common Issues & Solutions

**Jenkins Won't Start**
```bash
# Check Jenkins container logs
docker-compose logs jenkins

# Verify Java version in container
docker-compose exec jenkins java -version
```

**SonarQube Memory Issues**
```bash
# Verify vm.max_map_count setting
sysctl vm.max_map_count

# Should return 262144 or higher
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

# Check if Trivy is mounted correctly in Jenkins container
docker-compose exec jenkins which trivy
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

After completing Day-09, you'll be ready to build deployment pipelines that can deploy your containerized applications to different environments using the Docker images created by this CI/CD pipeline.

---


**🎉 Congratulations!** You've successfully built a production-ready CI/CD pipeline that demonstrates industry-standard DevOps practices. This foundation will serve you well in real-world scenarios and advanced DevOps implementations.