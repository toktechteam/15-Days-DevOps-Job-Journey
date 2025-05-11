
# 🐳 Day 9 – Jenkins + Docker Real-World Interview Questions & Answers

---

### 1. **How would you implement CI/CD for a full-stack app using Jenkins and Docker?**

**Answer:**
1. Create a `Jenkinsfile` with stages: checkout, test, build, scan, deploy
2. Use Docker to containerize frontend, backend, and DB
3. Store `Dockerfile` and `docker-compose.yml` in the repo
4. Push Docker images to a registry
5. SSH into EC2 and deploy using `docker-compose up -d`

---

### 2. **What is the purpose of `waitForQualityGate()` in a Jenkins pipeline with SonarQube?**

**Answer:**  
It pauses the pipeline until the SonarQube analysis is complete.  
If the quality gate fails, the build is aborted automatically — enforcing code quality standards.

---

### 3. **How do you perform security scanning in a Jenkins pipeline?**

**Answer:**  
Tools like **Trivy**, **Anchore**, or **Clair** can scan Docker images.  
In Jenkins:
```groovy
sh 'trivy image my-image:latest'
```
The scan results can be published using Jenkins plugins like Warnings Next Generation.

---

### 4. **How do you deploy to a remote EC2 instance using Jenkins?**

**Answer:**
1. Use `sshagent` with EC2 key
2. Copy the `docker-compose.yml` using `scp`
3. Run remote commands using `ssh`:
```bash
docker-compose down && docker-compose up -d
```

---

### 5. **What are the benefits of splitting Docker images for frontend and backend in your CI/CD pipeline?**

**Answer:**
- Better caching and faster builds
- Independent deployment and scaling
- Smaller image sizes per service
- Separation of concerns in microservices

---

### 6. **How do you ensure only high-quality code reaches production in a Jenkins pipeline?**

**Answer:**
- Run unit tests with coverage
- Integrate SonarQube for static analysis
- Use Quality Gates
- Run vulnerability scans with Trivy
- Fail the build on issues

---

### 7. **What is the role of credentials in Jenkins pipelines, and how do you manage them securely?**

**Answer:**  
Jenkins provides a **Credentials Manager** to store:
- SSH keys
- Docker registry creds
- API tokens

Access them in a pipeline using `withCredentials`, never hardcoded.

---

### 8. **What happens if your Docker image push fails in Jenkins? How do you handle it?**

**Answer:**
- Use `try/catch` or `post { failure { ... } }` blocks
- Print error logs
- Notify the team via Slack/email
- Avoid pipeline abortion with `|| true` if safe to continue

---

### 9. **What’s the difference between building Docker images inside Jenkins vs using an external Docker agent?**

**Answer:**
- Inside Jenkins: faster, but may overload the Jenkins host
- External agent: isolates build workloads, scalable, production-safe

---

### 10. **How do you clean up after a Jenkins build that uses Docker?**

**Answer:**
Use `post { always { ... } }` to remove built images:
```groovy
sh "docker rmi myapp-backend:${BUILD_NUMBER} || true"
```
This prevents disk bloat and keeps the Jenkins node healthy.

---
