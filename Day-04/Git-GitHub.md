
# 📦 Day 4: Git & GitHub Basics

Welcome to Day 2 of your DevOps journey!  
There’s **no DevOps without version control** — and that starts with Git & GitHub.

---

## 🔍 What is Git?

Git is a **distributed version control system** that helps track changes in your codebase over time.

- Think of it like a project timeline
- Enables collaboration, rollback, experimentation via branches

---

## 🌐 What is GitHub?

GitHub is a **cloud platform** that hosts Git repositories and allows:
- Team collaboration
- Code review through pull requests
- Automation with CI/CD
- Issue tracking and more

---

## 🛠️ Step-by-Step Git Setup

### ✅ Install Git

**Windows**:
1. Download Git from [https://git-scm.com/download/win](https://git-scm.com/download/win)
2. Install using default options
3. Open Git Bash

**macOS**:
```bash
brew install git
```

**Linux (Ubuntu/Debian)**:
```bash
sudo apt update
sudo apt install git
```

**Verify Installation**:
```bash
git --version
```

---

### 🔧 Configure Git

Run once:
```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

---

## 🚀 Working with Git & GitHub

### 🔁 Basic Workflow

```bash
git clone <repo-url>
cd repo-name

echo "Welcome to DevOps" > readme.md

git add .
git commit -m "Day 2 task"
git push origin main
```

---

## 📘 Key Git Concepts Explained

### 📁 Repository (Repo)
A folder or project tracked by Git. It can be local (your system) or hosted on GitHub.

### 🌿 Branch
A lightweight pointer to a commit. Used for feature development.
```bash
git checkout -b new-feature
```

### 🔀 Pull Request / Merge Request
A way to propose changes from one branch to another and request code reviews.

### 👀 Reviewers
People assigned to review pull requests before merging into the main codebase.

---


## 🔧 Git Rebase vs Merge – Explained Like a Pro

When you're working on a feature branch and want to sync it with the latest changes from `main`, you can either:

- **Merge** `main` into your feature branch
- **Rebase** your feature branch on top of `main`

---

### 🧠 What's the Difference?

#### 🟢 `git merge`
- Preserves the complete history, including the context of the feature branch
- Creates a **merge commit** in the graph

```bash
git checkout feature
git merge main
```

✅ Good when working in a **team**, for visibility and collaboration  
🟡 Downside: History can become cluttered with merge commits

---

#### 🔵 `git rebase`
- Rewrites history by placing your feature commits on top of the latest `main`
- Keeps history **linear and clean**

```bash
git checkout feature
git rebase main
```

✅ Great for **clean, understandable commit history**  
⚠️ Don’t rebase public/shared branches (it rewrites commit hashes)

---

### 🧭 Visual Example

Let’s say you have this history:

```
main:    A---B---C
                \
feature:         D---E
```

#### After `git merge main` (with merge commit):

```
main:    A---B---C-------G
                \     /
feature:         D---E
```

#### After `git rebase main`:

```
main:    A---B---C---D'---E'
```

D' and E' are the same changes but with new commit hashes, placed on top of C.

---

### 📌 Rebase in Action

```bash
# Start from feature branch
git checkout feature

# Apply commits from feature on top of main
git rebase main
```

If there’s a conflict:

```bash
# Git will pause
# You fix the conflict in files
git add .

# Continue rebase
git rebase --continue
```

---

### ⚖️ When to Use What?

| Use Case                        | Use `merge`                          | Use `rebase`                         |
|----------------------------------|--------------------------------------|--------------------------------------|
| Collaborative Team Work          | ✅ Shows true branching history      | ❌ Avoid rebase on shared branches   |
| Clean Solo Dev History           | ❌ Adds extra merge commits          | ✅ Perfect for tidy history          |
| Before Opening a Pull Request    | ❌ May look messy                    | ✅ Use rebase to squash/reorder     |
| After Conflicts                  | ✅ Easy to track changes             | ⚠️ Harder to debug sometimes        |

---

### 🔄 Pro Tip: Rebase + Squash for PRs

```bash
git rebase -i main
```

> Opens an interactive editor to squash commits, rename them, and clean up history before pushing.

---

### ❗ Important Warning

Never rebase branches that have been **pushed and shared** with others unless everyone agrees, because it rewrites history and may break others' sync.


---

## 💥 Merge Conflicts

Occur when two branches modify the same line of a file.

### ⚠️ Example:
Both `main` and `feature` updated `index.js` line 10 differently. On merge or rebase, Git flags a conflict.

### ✅ Resolution:
1. Git will mark the conflicting file.
2. Open it — you’ll see:
   ```
   <<<<<<< HEAD
   code from main
   =======
   code from feature
   >>>>>>> feature
   ```
3. Manually choose the correct version, remove conflict markers.
4. Then:
   ```bash
   git add <file>
   git commit
   ```

---

## 📘 More Git Basics

### 🔎 View Status & History
```bash
git status
git log --oneline --graph
```

### 🧼 Undo Changes
```bash
git checkout -- filename       # discard unstaged changes
git reset HEAD filename        # unstage file
```

### 📌 Stash Changes
Temporarily save changes
```bash
git stash
git stash apply
```

---

## 🔐 Using GitHub Securely

Use a **Personal Access Token (PAT)** if GitHub account uses 2FA.
Generate from: [https://github.com/settings/tokens](https://github.com/settings/tokens)

---

## 🎯 Outcome

✅ You now know:
- How to install and configure Git
- GitHub basics
- Working with commits, branches, and push
- Real-world flow of pull requests, reviews, rebasing, and resolving conflicts

---
