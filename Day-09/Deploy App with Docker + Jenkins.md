# 🐳 Day 9: Deploy App with Docker + Jenkins

Welcome to Day 9 of your DevOps Bootcamp!  
Today you'll learn how real-world CI/CD pipelines are built using **Docker + Jenkins** — and you’ll deploy a complete application using your own Jenkins pipeline.

---

## 📌 Getting Started – Setup Instructions First!

🛠️ **Before you begin**, follow the complete environment setup instructions in [`setup.md`](./setup.md) to install all necessary tools:

- ✅ Docker & Docker Compose on EC2
- ✅ Jenkins (running in Ec2)
- ✅ Trivy (for security scanning)
- ✅ SonarQube (for code analysis)

➡️ Once you’ve completed all setup steps, **come back here** and continue with the pipeline implementation.

---

## 🎯 Goal of the Day

You will:
- ✅ Use Jenkins to build Docker images
- ✅ Perform static code analysis using SonarQube
- ✅ Scan for security issues using Trivy
- ✅ Push images to a Docker registry
- ✅ Deploy to an EC2 server using Docker Compose

---

# ✅ EC2 Setup (Recap)

| Setting              | Value                                               |
|----------------------|-----------------------------------------------------|
| Name                 | devops-day09                                        |
| OS                   | Amazon Linux 2023 or Ubuntu 22.04                  |
| Instance type        | t3.medium                                           |
| Key pair             | Create new, download `.pem` file                    |
| Security group       | Allow SSH (22), HTTP (80), Ports (8080, 3000, 9000) |

SSH into EC2:
```bash
chmod 400 your-key.pem
ssh -i your-key.pem ec2-user@<your-ec2-public-ip>
```

---

## 📦 Recommended Project Structure

```
student-management-system/
├── backend/                  # Node.js backend
│   ├── server.js
│   ├── db.js
│   ├── package.json
│   ├── sonar-project.properties
│   └── __tests__/app.test.js
│
├── frontend/                 # Static frontend files
│   ├── index.html
│   ├── script.js
│   └── style.css
│
├── docker/                   # Docker build & compose
│   ├── Dockerfile.backend
│   ├── Dockerfile.frontend
│   └── docker-compose.yaml
│
├── ci-cd/                    # Jenkins Pipelines (layered)
│   ├── Jenkinsfile.part1
│   ├── Jenkinsfile.part2
│   ├── Jenkinsfile.part3
│   └── Jenkinsfile.full
│
├── database/                 # SQL setup
└── setup.md                 # Full installation & tool setup
```

---

## ⚙️ Jenkinsfile Overview

We’ll progressively build our pipeline through 4 Jenkinsfiles:

### ✅ `Jenkinsfile.part1` – Build & Install
- Checks out code
- Installs backend dependencies

### ✅ `Jenkinsfile.part2` – Build + Unit Tests
- Adds test execution
- Verifies application functionality

### ✅ `Jenkinsfile.part3` – Build + Scan + Push
- Builds Docker images
- Scans using Trivy
- Pushes to DockerHub

### ✅ `Jenkinsfile.full` – Complete CI/CD
- Adds SonarQube static analysis
- Runs unit tests
- Builds, scans, and pushes images
- Deploys to EC2 using Docker Compose

---

## 🔐 SonarQube Setup

Access: `http://<EC2-IP>:9000` → login: `admin/admin`

### backend/sonar-project.properties
```properties
sonar.projectKey=student-app
sonar.projectName=Student Management System
sonar.projectVersion=1.0

sonar.sources=.
sonar.language=js
sonar.sourceEncoding=UTF-8

sonar.host.url=http://<your-ec2-ip>:9000
sonar.login=${SONAR_TOKEN}
```

---

## 🎯 Task Flow Summary

1. 🔧 Complete setup from [`setup.md`](./setup.md)
2. ✅ Run Jenkinsfile.part1 and understand the output
3. ✅ Progress to Jenkinsfile.part2 → add testing
4. ✅ Run Jenkinsfile.part3 → build + scan + push
5. ✅ Finalize with Jenkinsfile.full for full CI/CD & deployment

---

## ✅ Outcome

By the end of Day 9, you will:
- ✅ Understand each CI/CD pipeline layer from build to deploy
- ✅ Learn static code & security analysis
- ✅ Be confident building and deploying real Docker apps via Jenkins

---

## ⏭️ Up Next: Day 10 – Terraform & Infrastructure as Code (IaC)!
