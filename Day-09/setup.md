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
## ⚙️ Step 3: Install Jenkins

### ✅ 3.1. Run Jenkins on Ec2 machine | Amazon Linux 2023 AMI 2023
```bash

sudo dnf update -y
sudo dnf install java-17-amazon-corretto -y
sudo dnf install git
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo dnf install jenkins -y
sudo systemctl start jenkins
sudo systemctl status jenkins
sudo chown -R jenkins:jenkins /var/lib/jenkins/*

```

### ✅ 3.2. Run Jenkins as container and mount volumes outside the container
```bash
sudo yum update -y
sudo yum install docker -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user
newgrp docker

docker run -d --name jenkins \
  -p 8080:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  jenkins/jenkins:lts

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
$ LATEST=$(curl -s https://api.github.com/repos/aquasecurity/trivy/releases/latest | grep browser_download_url | grep "Linux-64bit.rpm\"" | cut -d '"' -f 4)
$ wget $LATEST

```

### Ubuntu:
```bash
$ sudo apt install wget -y
$ wget https://github.com/aquasecurity/trivy/releases/latest/download/trivy_0.50.0_Linux-64bit.deb
$ sudo dpkg -i trivy_0.50.0_Linux-64bit.deb
```

Test Trivy:
```bash
$ trivy image alpine
```

---

## 📊 Step 5: Run SonarQube in Docker

```bash
$ cat <<EOF > docker-compose-sonar.yml
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

$ docker-compose -f docker-compose-sonar.yml up -d

```
---
## Install Sonar scaner to scan quality

```bash
$ cd /opt
$ sudo wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip
$ sudo unzip sonar-scanner-cli-*.zip
$ sudo mv sonar-scanner-5.0.1.3006-linux sonar-scanner
$ sudo ln -s /opt/sonar-scanner/bin/sonar-scanner /usr/bin/sonar-scanner
$ sonar-scanner --version


```

---
➡️ Open: `http://<EC2-IP>:9000` → Login with `admin/admin`
Impt: Install SonarQube Scanner Version 2.18 and cobertura plug-in in jenkins

🔧 After Plugin Install:
Configure SonarQube Scanner in Jenkins:

1. Go to Jenkins > Manage Jenkins > Configure System

   
![image](https://github.com/user-attachments/assets/de5952ed-557f-4b3b-9fc7-9210b20dd443)

3. Find the SonarQube servers section
4. Add your SonarQube server with name 'SonarLocal'
5. Provide the server URL and authentication token

![image](https://github.com/user-attachments/assets/16434021-0dd6-46c1-85c1-2174f8b7032a)



---
## Important Notes About Docker-Hub Image Push Stage:

### Credentials Configuration:

1. You must have credentials with ID 'docker-hub-creds' configured in Jenkins
2. To set this up, go to Jenkins > Manage Jenkins > Manage Credentials > Add Credentials

![image](https://github.com/user-attachments/assets/64e8b18d-d4ab-4da9-8a35-dfcf9fd16cc4)

3. Select "Username with password" type and set the ID to 'docker-hub-creds'


![image](https://github.com/user-attachments/assets/c00ed29b-48f6-49b4-be30-04d4a29e51b1)


![image](https://github.com/user-attachments/assets/e183a3c7-55d9-4b90-94ba-054b172b912e)
   
---

## Create GitHub Cred. in Jenkins 


1. Create cred. for GitHub as well. To create cred. for GitHub you should have Github-Token with you.
2. This is required as password for your github account.

   ![image](https://github.com/user-attachments/assets/1ea9f1d0-10c1-4ed0-bfba-0930a979c56e)
   
---

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
