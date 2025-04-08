# 📘 README.md – Jenkins CI/CD Pipeline with Docker & Amazon ECR

This project sets up a complete CI/CD pipeline using Jenkins, Docker, and AWS ECR as part of a real-world 3-tier DevOps setup.

---

## 🔧 What You'll Learn
- Setting up Jenkins inside Docker (with AWS CLI + Docker CLI)
- Integrating Jenkins with GitHub for automatic code checkout
- Building Docker images for frontend and backend services
- Logging in to Amazon ECR and pushing images
- Preparing for ECS deployment via Terraform (next step)

---

## 🗂️ Project Structure
Your GitHub repo contains:

```bash
15-days-devops/
├── README.md
├── jenkins-docker
│   ├── Dockerfile              # Custom Jenkins image with Docker & AWS CLI
│   └── install.sh              # Shell script to install Jenkins
└── jenkins-pipelines
    ├── Jenkinsfile             # CI/CD pipeline configuration
    ├── backend
    │   ├── Dockerfile          # Backend Dockerfile (Node.js app)
    │   ├── package.json        # Node.js dependencies
    │   └── server.js           # Express app
    ├── docker-compose.yml      # For local multi-container setup
    ├── frontend
    │   ├── Dockerfile          # Frontend Dockerfile (NGINX)
    │   ├── index.html          # Static webpage
    │   └── nginx.conf          # Custom NGINX configuration
    └── install.sh              # Setup script for Jenkins pipeline
```

---

## 🚀 Setup Summary

### ✅ Jenkins Setup (Docker-based)
Jenkins is installed using a custom Docker image with:
- Docker CLI
- AWS CLI v2
- Docker group permissions for Jenkins user

### ✅ Jenkins Runs With:
- Docker socket mounted (`/var/run/docker.sock`)
- Port `8081` exposed for UI access
- `jenkins_home` persisted in a named volume

### ✅ IAM Role for EC2 Instance (where Jenkins runs)
Permissions include:
- Full access to Amazon ECR
- ECS task registration and updates
- IAM PassRole
- CloudWatch Logs access (for ECS tasks)

---

## ✅ Amazon ECR
To store Docker images, you need to create two ECR repositories.

### 📌 Commands to Create ECR Repositories
Run the following commands from your AWS CLI configured terminal:

```bash
aws ecr create-repository --repository-name 3tier-backend
aws ecr create-repository --repository-name 3tier-frontend
```

These commands will create two private ECR repositories named `3tier-backend` and `3tier-frontend` in your default AWS region.

---

## 🧪 Pipeline Workflow (via Jenkinsfile)
1. **Checkout Code** – From GitHub `dev` branch
2. **Login to ECR** – Using `aws ecr get-login-password`
3. **Build & Push Images** – Docker images are tagged and pushed to ECR

---

## ✅ Expected Outcome
Once the Jenkins pipeline runs successfully:
- Your Node.js and NGINX images are built
- Both images are securely pushed to Amazon ECR
- You’re ready to deploy them on ECS via Terraform (next step)

