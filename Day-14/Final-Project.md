# 🚀 Final Project: 3-Tier DevOps Pipeline

Welcome to your **Final Hands-On Project** of this DevOps Bootcamp!
You are now going to bring together everything you've learned into a real-world, production-grade setup.

---

# 🎯 Objective

Deploy a full 3-tier sample application using:

- Git + GitHub (Version Control)
- Docker + Docker Compose (Containerization)
- Jenkins (CI/CD Pipeline)
- AWS EC2 + Terraform (Infrastructure Provisioning)
- Prometheus + Grafana (Monitoring & Observability)

---

# 🛠 What You Will Build

A **Student Management System**:
- **Frontend** — Web interface (HTML, CSS, JavaScript)
- **Backend** — Node.js REST API
- **Database** — MySQL

All integrated with:
- CI/CD Pipeline (via Jenkins)
- AWS Cloud Deployment
- Real-time Monitoring Stack

---

# 📂 Project Repository Structure

```bash
student-management-system/
├── frontend/                 # Frontend code
├── backend/                  # Backend code
├── database/                 # Database scripts
├── docker-compose.yml        # Docker Compose setup
├── terraform/                # AWS Infra as Code (Terraform)
├── monitoring/               # Prometheus + Grafana setup
├── Jenkinsfile               # Jenkins CI/CD Pipeline
├── .github/workflows/         # GitHub Actions (optional CI/CD)
└── README.md                  # Project Documentation
```

---

# 📋 Setup Instructions

Follow these steps exactly (already prepared inside your project files):

### 1. Development Setup (Local Testing)
- Setup MySQL Database
- Run Backend locally
- Serve Frontend via simple server (Python)

### 2. Docker Containerization
- Use Docker Compose to spin up:
    - MySQL DB
    - Backend API
    - Frontend Server

```bash
docker-compose up -d
```

Accessible at: `http://localhost:8080`

### 3. AWS Infrastructure Setup
- Provision EC2, VPC, Security Groups, Load Balancer, ECR repos using Terraform:

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

- Push Docker images to ECR
- Deploy containers on ECS

### 4. CI/CD Pipeline
- Setup Jenkins Pipeline with:
    - Code Checkout
    - Build
    - Test
    - Docker Image Build
    - Push to ECR
    - Deploy on ECS

### 5. Monitoring Setup
- Navigate to `monitoring/` directory
- Deploy Prometheus + Grafana stack

```bash
cd monitoring
docker-compose up -d
```

Access Dashboards:
- Prometheus: `http://localhost:9090`
- Grafana: `http://localhost:3001` (admin/admin)

---

# 🎯 Final Project Outcome

By completing this project, you will:
- Build and deploy a full-stack application
- Manage infrastructure with Terraform
- Automate deployments with Jenkins and GitHub Actions
- Monitor applications using Prometheus and Grafana
- Be able to show a real-world project in your DevOps portfolio!

---

# ✅ Important Notes

- Students should **clone** the project repo first.
- Follow the `README.md` as the main guide.
- Terraform backend (state file) setup must be secure (use S3 + DynamoDB optional advanced task).
- Grafana dashboards can be customized for bonus learning.

---

# ✨ Pro Tip for Students

> Treat this like a **real-world project** you would deliver in a company.
> Document your learnings and screenshots — this becomes your LinkedIn/Portfolio showcase!

---

# TheOpsKart | Real-World DevOps Training.
