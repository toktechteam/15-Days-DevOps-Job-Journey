
# 🚀 Day 7: CI/CD Basics + Jenkins Setup

Welcome to Day 7 of your DevOps Bootcamp!  
Today we dive into **CI/CD fundamentals** and set up Jenkins — the most popular open-source automation tool.

---

## 🧠 A. What is CI/CD?

CI/CD stands for:
- **Continuous Integration (CI)**: Automatically build & test your code every time it's pushed.
- **Continuous Delivery (CD)**: Automatically deliver tested code to a staging/production environment.

### ✅ Benefits:
- Faster software delivery
- Fewer bugs in production
- Repeatable and auditable deployments

---

## 🔧 B. Why Jenkins?

Jenkins is:
- ✅ Open-source
- ✅ Extensible with 1000+ plugins
- ✅ Integrates with GitHub, Docker, Terraform, Kubernetes, Slack, and more
- ✅ Can run on EC2, Docker, or even Kubernetes

---

## 🛠️ C. Install Jenkins on EC2 (Amazon Linux 2023 AMI 2023)

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

### ✅ 2. Run Jenkins as container and mount volumes outside the container
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
---

### ✅ 3. Allow Port 8080 in Security Group
Go to AWS Console → EC2 → Security Groups → Inbound rules  
Allow:
- TCP port 8080 from your IP or `0.0.0.0/0` (for testing)

---

## 🌐 Access Jenkins in Browser

1. Visit: `http://<your-ec2-ip>:8080`
2. Retrieve Admin Password:
```bash
docker exec -it <container-id> /bin/bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```
3. Paste it into the browser to unlock Jenkins

---

## 🔧 Complete Jenkins Setup Wizard

1. Click **Install Suggested Plugins**
2. Create your **Admin user**
3. Click **Start using Jenkins**

---

## 📘  Extra Setup Tips (Highly Recommended)

- Install Git plugin for source control support
- Install Docker plugin if you're building container images
- Install Blue Ocean for a modern UI experience
- Configure system → Set JDK and Git paths
- Set up a local or cloud-based GitHub repo for project integration

---

## 📦  Where Jenkins Stores Data

- Configs: `/var/lib/jenkins/config.xml`
- Jobs: `/var/lib/jenkins/jobs/`
- Logs: `/var/log/jenkins/jenkins.log`
- Plugins: `/var/lib/jenkins/plugins/`

---

## 🎯 Task for Today

- ✅ Install Jenkins on EC2
- ✅ Access Jenkins dashboard in your browser
- ✅ Complete the setup wizard and install suggested plugins
- ✅ Create your first Jenkins user

---

## ✅ Outcome

By end of Day 7, you will:
- ✅ Understand CI/CD fundamentals
- ✅ Set up and run Jenkins on EC2
- ✅ Know how Jenkins integrates with Git, Docker, and other tools
- ✅ Be ready to automate your first real project pipeline

---

## ⏭️ Up Next: Day 8 – Create your first Jenkins CI/CD pipeline using GitHub!
