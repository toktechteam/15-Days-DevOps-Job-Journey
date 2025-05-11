
# 🧪 Day 8 – Jenkins Pipeline Interview Questions & Answers

---

### 1. **What is a Jenkins Pipeline and why is it useful?**

**Answer:**  
A Jenkins Pipeline is a way to define the build, test, and deploy stages as **code** (Jenkinsfile).  
Benefits include:
- Version control for automation scripts
- Easier debugging and repeatability
- Scalable for complex workflows

---

### 2. **What’s the difference between a Freestyle Job and a Pipeline Job?**

**Answer:**
- **Freestyle Job**: Configured via Jenkins UI, limited flexibility
- **Pipeline Job**: Defined in a Jenkinsfile (Groovy syntax), supports branching, parallelism, logic, etc.  
  Pipeline is preferred for real CI/CD in teams.

---

### 3. **What are the two types of pipeline syntax supported in Jenkins?**

**Answer:**
- **Declarative Pipeline**: Structured and beginner-friendly
- **Scripted Pipeline**: Full Groovy-based scripting, more flexible but complex

---

### 4. **How do you define multiple stages in a Jenkinsfile?**

**Answer:**
```groovy
pipeline {
  agent any
  stages {
    stage('Build') { steps { echo 'Build stage' } }
    stage('Test') { steps { echo 'Test stage' } }
    stage('Deploy') { steps { echo 'Deploy stage' } }
  }
}
```

---

### 5. **How can you trigger a Jenkins pipeline from GitHub?**

**Answer:**
- Configure **GitHub Webhook**
- Jenkins must have `GitHub` plugin installed
- Job type should be **"Pipeline script from SCM"**
- Jenkins will automatically run when `git push` happens

---

### 6. **What does `agent any` mean in a Jenkinsfile?**

**Answer:**  
It tells Jenkins to run the pipeline on **any available agent or node**.  
You can replace it with specific labels or docker containers.

---

### 7. **Can Jenkinsfiles support conditionals and loops?**

**Answer:**  
Yes. Using the `when` condition for stages:
```groovy
stage('Deploy') {
  when {
    branch 'main'
  }
  steps {
    echo 'Deploying only on main branch'
  }
}
```

---

### 8. **How do you handle post-build actions like notifications in pipelines?**

**Answer:**
```groovy
post {
  success { echo 'Build succeeded' }
  failure { echo 'Build failed' }
}
```

---

### 9. **Where is the Jenkinsfile typically stored?**

**Answer:**  
Inside the root of your GitHub repository —  
Jenkins will look for `Jenkinsfile` during pipeline execution when using "Pipeline from SCM".

---

### 10. **What are some common reasons for pipeline failures?**

**Answer:**
- Wrong Git URL or credentials
- Incorrect Jenkinsfile syntax
- Missing plugins
- Ports/services not available during test/deploy
- External service failure (e.g., DB, Docker daemon)

---
