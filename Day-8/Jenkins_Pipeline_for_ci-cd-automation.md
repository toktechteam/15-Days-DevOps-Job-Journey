
# 🧪 Day 8: Jenkins Pipeline for CI/CD Automation

Welcome to Day 8 of your DevOps Bootcamp!  
Today you’ll learn how to **automate everything** using Jenkins pipelines — from build, to test, to deployment.

---

## 🧠 A. What is a Jenkins Pipeline?

A **pipeline** is a series of **automated steps** that Jenkins runs to:
- ✅ Build your code
- ✅ Run tests
- ✅ Deploy to staging/production

Instead of clicking buttons, you write this flow as **code**. This makes it reusable, version-controlled, and scalable.

---

## 🚦 B. Types of Jenkins Jobs

| Job Type            | Description                                               |
|---------------------|-----------------------------------------------------------|
| **Freestyle Job**   | GUI-based job. Great for beginners                        |
| **Declarative Pipeline** | Code-based (Jenkinsfile). Preferred for real-world CI/CD |

---
# ✅ Click “Launch Instance”

| Setting              | Value                                               |
|----------------------|-----------------------------------------------------|
| Name                 | devops-day08                                        |
| OS                   | Amazon Linux 2023 AMI 2023, ami-05572e392e80aee89   |
| Instance type        | t3.medium                                           |
| Key pair             | Create new, download `.pem` file                    |
| Security group       | Allow SSH (22), HTTP (80), Custom Port (8080, 3000) |

Launch and Connect via SSH



### ✅ 1. SSH into EC2
```bash
chmod 400 your-key.pem
ssh -i your-key.pem ubuntu@<your-ec2-public-ip>

```
---
## Install Jenkins on ec2 machine using docker

```
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

---

## 🛠️ C. Part 1 – Create a Freestyle Job (GUI-Based)

### ✅ 1. Go to Jenkins → Click "New Item"
- Name: `freestyle-demo`
- Type: **Freestyle project**

### ✅ 2. Configure GitHub Source (Optional)
Under `Source Code Management`, choose:
- Git → Enter repo URL  
  (*Skip this if you don’t want to use a repo yet*)

### ✅ 3. Add Build Step
Choose `Execute shell`, then add:
```bash
echo "Welcome to Jenkins Pipeline"
echo "Building project..."
```

### ✅ 4. Save → Click "Build Now"

### ✅ 5. View Output
Click on build → Console Output  
You’ll see your custom echo messages

---

## 🧾 D. Part 2 – Create a Code-Based Pipeline (Jenkinsfile)

### ✅ 1. Create a GitHub Repo with a `Jenkinsfile`

Create a file named `Jenkinsfile` in your repo:

```groovy
pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                echo '🔨 Building the app...'
            }
        }

        stage('Test') {
            steps {
                echo '✅ Running tests...'
            }
        }

        stage('Deploy') {
            steps {
                echo '🚀 Deploying the app...'
            }
        }
    }
}
```

Push this to your GitHub repo.

---

### ✅ 2. In Jenkins → New Item → Pipeline Job

- Name: `code-pipeline-demo`
- Type: **Pipeline**

### ✅ 3. Scroll to "Pipeline Script from SCM"

- SCM: Git
- Repo URL: `https://github.com/YOUR_USERNAME/YOUR_REPO`
- Script Path: `Jenkinsfile`

Save → Click **Build Now**

---

## 🔁 E. Compare Freestyle vs Jenkinsfile

| Feature               | Freestyle Job       | Jenkinsfile Pipeline      |
|-----------------------|---------------------|---------------------------|
| UI or Code-based      | UI                  | Code (Groovy)             |
| Reusable              | ❌ Not versioned     | ✅ Stored in Git           |
| Complex Logic Support | ❌ Limited           | ✅ Advanced conditions     |
| CI/CD Ready           | ❌ Manual plugins    | ✅ Modern DevOps-ready     |

---

## 🎯 Task for Today

- ✅ Create a freestyle job and run shell steps
- ✅ Push a Jenkinsfile to GitHub
- ✅ Create a pipeline job in Jenkins connected to that repo
- ✅ Run both jobs and observe the differences

---

## ✅ Outcome

By end of Day 8, you will:
- ✅ Understand what Jenkins pipelines are
- ✅ Create both UI-based and code-based jobs
- ✅ Automate multi-stage workflows using Jenkinsfile
- ✅ Integrate Jenkins with your GitHub repo

---

## ⏭️ Up Next: Day 9 – Docker + Jenkins to build and deploy real-world apps!
