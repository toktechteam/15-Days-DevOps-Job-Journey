
# 🚀 Day 7 – Jenkins + CI/CD Interview Questions & Answers (Real-World Focus)

---

### 1. **What is the difference between Continuous Integration, Continuous Delivery, and Continuous Deployment?**

**Answer:**
- **CI**: Automatically build and test code when pushed to the repo
- **CD (Delivery)**: Automatically prepare code for release to staging
- **CD (Deployment)**: Automatically push tested code all the way to production

---

### 2. **How does Jenkins fit into a CI/CD pipeline?**

**Answer:**  
Jenkins automates:
- Cloning the code (from GitHub/GitLab)
- Building the code (Java, Node, etc.)
- Running tests
- Packaging and deploying (to S3, EC2, Docker, etc.)

It acts as the **orchestrator** that connects your dev → test → deploy workflow.

---

### 3. **Explain a basic Jenkins pipeline setup.**

**Answer:**  
A basic Jenkins pipeline has these stages:
1. `checkout`: Pull code from Git repo
2. `build`: Compile or package the app
3. `test`: Run unit/integration tests
4. `deploy`: Push to staging or production

---

### 4. **Where does Jenkins store job configurations and build logs?**

**Answer:**
- Configs: `/var/lib/jenkins/jobs/<job-name>/config.xml`
- Logs: `/var/lib/jenkins/jobs/<job-name>/builds/<build-id>/log`

---

### 5. **What is the difference between freestyle and pipeline jobs in Jenkins?**

**Answer:**
- **Freestyle**: UI-based, limited flexibility, GUI configuration
- **Pipeline (Jenkinsfile)**: Code-based (Groovy), supports advanced stages, conditionals, parallelism

---

### 6. **How would you trigger a Jenkins build when code is pushed to GitHub?**

**Answer:**
- Enable **GitHub Webhooks**
- Configure Jenkins job with **"GitHub hook trigger for GITScm polling"**
- GitHub will call Jenkins endpoint on every `git push`

---

### 7. **How do you securely store credentials in Jenkins?**

**Answer:**  
Use **Jenkins Credentials Manager**:
- Add secrets (API keys, passwords)
- Access them in pipeline via `credentialsId`
```groovy
withCredentials([usernamePassword(credentialsId: 'aws-creds', ...)])
```

---

### 8. **Can Jenkins build Docker images and push to ECR or Docker Hub? How?**

**Answer:**  
Yes. Steps:
1. Install Docker on Jenkins server
2. Configure credentials for registry
3. Use `docker build`, `docker tag`, `docker push` in pipeline
4. For ECR, use AWS CLI login

---

### 9. **What plugins would you install in Jenkins for a modern DevOps pipeline?**

**Answer:**
- Git / GitHub
- Docker / Docker Pipeline
- Pipeline Utility Steps
- Blue Ocean (optional UI)
- Credentials Binding
- Email Extension / Slack Notifier

---

### 10. **How do you ensure pipeline failures are visible to the team?**

**Answer:**
- Use Slack or email notifications on `failure` or `unstable`
- Archive reports (`junit`, `html`, etc.)
- Add `post` conditions in pipeline to handle failures

---