# 📦 Day 9 – Setup Instructions

This guide helps you prepare your EC2 environment for running a complete Jenkins-based CI/CD pipeline with Docker, Trivy, and SonarQube.

---

## ✅ Prerequisite: Launch EC2 Instance

| Setting              | Value                                                    |
|----------------------|----------------------------------------------------------|
| Name                 | devops-day09                                             |
| OS                   | Amazon Linux 2023 AMI 2023, ami-05572e392e80aee89        |
| Instance type        | t3.medium                                                |
| Key pair             | Create new, download `.pem` file                         |
| Security group       | Allow SSH (22), HTTP (80), Custom TCP (8080, 3000, 9000) |
### Connect to EC2:
```bash
chmod 400 your-key.pem
ssh -i your-key.pem ec2-user@<EC2-PUBLIC-IP>
```

---

## 🐳 Step 1: Install Docker

### Amazon Linux:
```bash
sudo yum update -y
sudo amazon-linux-extras enable docker
sudo yum install docker -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user
newgrp docker
```

### Ubuntu:
```bash
sudo apt update && sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
newgrp docker
```

---

## ⚙️ Step 2: Install Docker Compose

```bash
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
```

---

## ☁️ Step 3: Run Jenkins (Using Docker)

```bash
sudo dnf update -y
sudo dnf install java-17-amazon-corretto -y
java -version
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo dnf install jenkins -y
sudo systemctl start jenkins
sudo systemctl enable jenkins
sudo systemctl status jenkins

sudo usermod -aG docker jenkins
sudo chmod 777 /var/run/docker.sock
sudo systemctl restart jenkins

```

📌 To get the admin password:
```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

➡️ Open in browser: `http://<EC2-IP>:8080`

---

## 🔐  Node.js & npm (for backend builds)

```bash
Install 

$ curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
$ sudo yum install -y nodejs

```
---

## 🔐 Step 4: Install Trivy (for Image Scanning)

### Amazon Linux:
```bash
LATEST=$(curl -s https://api.github.com/repos/aquasecurity/trivy/releases/latest | grep browser_download_url | grep rpm | cut -d '"' -f 4)
wget $LATEST
sudo rpm -ivh $(basename $LATEST)
 $ remove all other downloads file only rpm 64 bit needed on your laptop.
rpm -ivh trivy_0.61.1_Linux-64bit.rpm

```

### Ubuntu:
```bash
sudo apt install wget -y
wget https://github.com/aquasecurity/trivy/releases/latest/download/trivy_0.50.0_Linux-64bit.deb
sudo dpkg -i trivy_0.50.0_Linux-64bit.deb
```

Test Trivy:
```bash
trivy image alpine
```

---

## 📊 Step 5: Run SonarQube in Docker

```bash
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

docker-compose -f docker-compose-sonar.yml up -d

```
---
## Install Sonar scaner to scan quality

```bash
cd /opt
sudo wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip
sudo unzip sonar-scanner-cli-*.zip
sudo mv sonar-scanner-* sonar-scanner
sudo ln -s /opt/sonar-scanner/bin/sonar-scanner /usr/bin/sonar-scanner
sonar-scanner --version


```

---
➡️ Open: `http://<EC2-IP>:9000` → Login with `admin/admin`
Impt: Install SonarQube ScannerVersion 2.18 version plug-in in jenkins

🔧 After Plugin Install:
Configure SonarQube Server in Jenkins:

1. Go to Jenkins > Manage Jenkins > Configure System
2. Find the SonarQube servers section
3. Add your SonarQube server with name 'SonarLocal'
4. Provide the server URL and authentication token

---
## Important Notes About Docker-Hub Image Push Stage:

### Credentials Configuration:

1. You must have credentials with ID 'docker-hub-creds' configured in Jenkins
2. To set this up, go to Jenkins > Manage Jenkins > Manage Credentials > Add Credentials
3. Select "Username with password" type and set the ID to 'docker-hub-creds'


### Docker Hub Repository Access:

1. Ensure the user has permission to push to repositories named 'student-backend' and 'student-frontend'
2. If you want to push to a specific Docker Hub account, update the environment variables to include your username:
```environment {
BACKEND_IMAGE = "yourusername/student-backend"
FRONTEND_IMAGE = "yourusername/student-frontend"
}
```

### Network Connectivity:

1. Your Jenkins server must have network access to Docker Hub
2. Corporate firewalls might block this connection, so check your network settings if you encounter issues
---

## ✅ You're Ready!
Now return to `Day 9: Deploy App with Docker + Jenkins` and begin the pipeline setup!
