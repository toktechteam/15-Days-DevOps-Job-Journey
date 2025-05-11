
# ✅ Day 2 – Git & GitHub Interview Questions & Answers

---

### 1. **What is Git, and how does it help in DevOps workflows?**

**Answer:**  
Git is a distributed version control system used to track changes in source code during software development. It allows multiple developers to work on the same codebase simultaneously without overwriting each other's changes. In DevOps, Git enables efficient collaboration, experimentation through branching, rollback to stable versions, and smooth integration with CI/CD tools. It forms the backbone of source code management in any DevOps pipeline.

---

### 2. **What is the difference between a Git repository and a GitHub repository?**

**Answer:**  
A **Git repository** is a local folder on your machine that is being tracked by Git — it stores your commit history, branches, and changes.  
A **GitHub repository** is a cloud-hosted version of your Git repository that allows remote access, collaboration, pull requests, and integration with DevOps tools (like GitHub Actions, Jenkins, or Terraform). GitHub makes it easier to collaborate and manage codebases in teams.

---

### 3. **Explain the steps to configure Git after installation. Why is this step necessary?**

**Answer:**  
After installing Git, you should configure your identity using:

```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

This step is necessary because Git uses this information to tag each commit with the author's name and email address. It helps in tracking who made which changes, especially in collaborative environments.

---

### 4. **What are branches in Git and why do we use them? Provide a use-case.**

**Answer:**  
A **branch** in Git is like a parallel line of development. You can create branches to work on features or fixes without affecting the main codebase.

**Use case:**  
If you're building a login feature, you can run:
```bash
git checkout -b login-feature
```
Now you can develop and commit without interfering with the `main` branch. Once done, the feature can be merged back into `main`.

---

### 5. **What’s the difference between `git merge` and `git rebase`? When would you use each?**

**Answer:**
- `git merge` combines changes from one branch into another and creates a **merge commit**. It preserves the actual history and is great for team collaboration.
- `git rebase` re-applies your branch's commits on top of another branch. It rewrites commit history and gives a **linear, cleaner history**.

**Use `merge`** when working with teams to maintain context.  
**Use `rebase`** for solo work or before a PR to clean up commits.

---

### 6. **How do you resolve a merge conflict? What do the conflict markers look like?**

**Answer:**  
Merge conflicts happen when Git can't automatically resolve differences between branches.

Steps:
1. Git marks the file with conflict markers like:
   ```bash
   <<<<<<< HEAD
   code from main
   =======
   code from feature
   >>>>>>> feature
   ```
2. Manually edit the file and keep the correct version.
3. Remove the conflict markers.
4. Stage and commit:
   ```bash
   git add filename
   git commit
   ```

---

### 7. **Explain how a Pull Request (or Merge Request) works in GitHub. What’s its purpose?**

**Answer:**  
A **Pull Request (PR)** is a GitHub feature that lets developers propose changes to a codebase.
- A developer pushes code to a feature branch
- Then opens a PR to merge it into the main branch
- Reviewers can comment, request changes, and approve the code

The PR process ensures code quality, catches bugs early, and promotes collaboration in teams.

---

### 8. **How can you squash commits using Git? When is it recommended?**

**Answer:**  
You can squash commits using interactive rebase:

```bash
git rebase -i main
```

This opens an editor where you can replace `pick` with `squash` to combine commits.  
**Recommended use:** Before submitting a PR — to clean up commit history by merging "Work in progress" commits into one meaningful commit.

---

### 9. **What’s the role of Reviewers in a GitHub workflow?**

**Answer:**  
Reviewers are team members assigned to check a Pull Request before it's merged. Their role is to:
- Review code quality
- Ensure best practices are followed
- Catch bugs or performance issues
- Approve or request changes

They help maintain high-quality, maintainable, and secure codebases.

---

### 10. **What is a Personal Access Token (PAT) and when do you need it in GitHub?**

**Answer:**  
A **Personal Access Token (PAT)** is an alternative to using your GitHub password for command-line or third-party tool access — especially when Two-Factor Authentication (2FA) is enabled.

When pushing code via HTTPS, instead of entering your password, you use your PAT for authentication.

Generate it from: [https://github.com/settings/tokens](https://github.com/settings/tokens)

---
