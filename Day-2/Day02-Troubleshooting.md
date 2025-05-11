# 🚑 Day-02 Troubleshooting Guide & Problem Analysis

Welcome to the official **Troubleshooting & Analysis Guide** for Day-02 deployment issues.  
This document summarizes all the real-world problems we faced, root cause analysis, and practical working solutions that fixed the setup.

---

# 1. Problem: Backend Crashed After SSH Disconnect

### Problem Statement:
- After starting backend using `npm start`, when SSH session closed, backend server stopped.
- Result: ALB could not forward `/api/students` requests, causing frontend API calls to fail.

### Suggested Solution:
- Install and use **PM2** to run backend server persistently.
- Commands:
```bash
sudo npm install -g pm2
cd ~/backend
pm2 start server.js --name backend-service
pm2 save
pm2 startup
```
✅ Now backend survives reboot, SSH disconnection, network interruptions.

---

# 2. Problem: ALB DNS Not Opening the Application

### Problem Statement:
- ALB DNS was not showing the frontend application.
- Even though EC2 Public IP was serving application correctly.

### Root Cause:
- EC2 backend and frontend were served on **port 8080**.
- ALB default listener expected application on **port 80**.
- Mismatch between ALB listener port and EC2 target port.

### Suggested Solution:
- Correct the Target Group settings:
    - Target Port: **8080**
    - Target Type: **Instance**
- ALB Listener Rule:
    - Listen on **port 80** → Forward to Target Group **port 8080**
- Ensure EC2 security group allowed inbound traffic on 8080.

✅ Now ALB forwards correctly to EC2 backend/frontend.

---

# 3. Problem: 404 Error on `/api/students`

### Problem Statement:
- Opening `http://ALB-DNS/api/students` returned 404 File Not Found.
- Backend API was unreachable.

### Root Cause:
- Python HTTP server was running and catching requests.
- Backend Node.js server was not alive earlier.

### Suggested Solution:
- Start Node.js backend properly with PM2 (Step 1).
- Ensure backend server listens on `0.0.0.0:3000` (dynamic or fixed port).
- In frontend `script.js`, point API calls correctly to backend API URL if needed.

✅ Backend API now accessible through ALB DNS.

---

# 4. Problem: EC2 MySQL Root Access Denied

### Problem Statement:
- While connecting to MySQL using `mysql -u root -p`, error `Access denied for user 'root'@'localhost'` appeared.

### Root Cause:
- By default, MySQL root user on Ubuntu uses **auth_socket** authentication, not password.

### Suggested Solution:
- Reconfigure root user to use password authentication:
```bash
sudo mysql
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root';
FLUSH PRIVILEGES;
exit
```
✅ After this, normal `mysql -u root -p` login works.

---

# 🔥 Final System Architecture After Fixes

| Component | Status |
|-----------|--------|
| Backend Node.js | Running via PM2 ✅ |
| Frontend Python Server | Serving static files ✅ |
| MySQL Database | Running and accessible ✅ |
| ALB Forwarding | Correct on port 80 → 8080 ✅ |
| Route53 Custom Domain | (Optional) can now point to ALB ✅ |

---

# 🎯 Key Learning and Recommendations

- Always run backend using **process manager** like PM2 in production.
- Always match **ALB Listener Port** and **Target Group Port** correctly.
- Always bind services to **0.0.0.0**, not localhost only.
- Always verify security groups allow correct inbound ports.
- Use Terraform, Docker Compose, and CI/CD for automation in bigger setups.
