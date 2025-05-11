
# 🐳 Day 6: Docker Compose & Multi-Container Setup

Welcome to Day 6 of your DevOps journey!  
Today we level up: you'll learn how to spin up **multiple containers** using Docker Compose. Real-world applications aren’t made of a single service — they need databases, backends, frontends… all running together.

---

## 🧠 A. Why Docker Compose?

Docker Compose lets you:
- Define all your app’s services in a **single YAML file**
- Start/stop everything with **one command**
- Link containers together via built-in **networks**
- Add volumes and configs with ease

---

## 📦 B. Quick Start: Compose a Simple Setup

# ✅ Click “Launch Instance”

| Setting              | Value                                                       |
|----------------------|-------------------------------------------------------------|
| Name                 | devops-day06                                                |
| OS                   | Ubuntu Server 24.04, SSD Volume Type, ami-075686beab831bb7f |
| Instance type        | t2.micro                                                    |
| Key pair             | Create new, download `.pem` file                            |
| Security group       | Allow SSH (22), HTTP (80), Custom Port (8080, 3000)         |

Launch and Connect via SSH

```bash
chmod 400 your-key.pem
ssh -i your-key.pem ubuntu@<your-ec2-public-ip>

```
# Install Docker & Docker-Compose

```bash
$ sudo apt update -y
$ sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/docker.gpg
$ sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
$ sudo apt update
$ sudo apt install -y docker-ce docker-ce-cli containerd.io

$ sudo systemctl start docker
$ sudo systemctl enable docker
$ sudo usermod -aG docker $USER
$ sudo systemctl enable docker
$ sudo chmod 777 /var/run/docker.sock



```

---
---
### Basic `docker-compose.yml`

```yaml
version: '3'
services:
  web:
    image: nginx
    ports:
      - "8080:80"

  db:
    image: mysql:5.7
    environment:
      MYSQL_ROOT_PASSWORD: rootpass
```

Steps:
```bash
mkdir multi-app && cd multi-app
vim docker-compose.yml     # paste the YAML
docker-compose up -d
docker ps
```

Visit [http://localhost:8080](http://localhost:8080) to verify.

---

## 🚀 C. Real DevOps App Using Docker Compose

Now let’s go pro. Below is a **full working docker-compose setup** for a Student Management App with:

- ✅ MySQL Database
- ✅ Node.js Backend API
- ✅ Frontend UI (React or Static HTML)
- ✅ Volume mount for MySQL data
- ✅ Health check + auto-restart

---



### 🔧 `docker-compose.yml`

```yaml
version: '3.8'

services:
  # MySQL Database
  mysql:
    image: mysql:8.0
    container_name: student-management-db
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: root_password
      MYSQL_DATABASE: student_management
    ports:
      - "3306:3306"
    volumes:
      - mysql-data:/var/lib/mysql
      - ./database/setup.sql:/docker-entrypoint-initdb.d/setup.sql
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-u", "root", "-proot_password"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Backend Service
  backend:
    build:
      context: .
      dockerfile: Dockerfile.backend
    container_name: student-management-backend
    restart: always
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DB_HOST=mysql
      - DB_USER=root
      - DB_PASSWORD=root_password
      - DB_NAME=student_management
    depends_on:
      mysql:
        condition: service_healthy

  # Frontend Service
  frontend:
    build:
      context: .
      dockerfile: Dockerfile.frontend
    container_name: student-management-frontend
    restart: always
    ports:
      - "8080:8080"
    depends_on:
      - backend

volumes:
  mysql-data:
```

### ✅ How to Run

1. Clone Day-6 folder on your ec2 machine
2. Go to demo-2->> student-management-system
3. Update the script.js file  line 2 with your ec2-public IP, under fronend folder.
4. Run:
```bash
docker-compose up -d --build
```

4. Verify containers:
```bash
docker ps
```

5. Open:
- Frontend: [http://your-ec2-public-ip:8080](http://localhost:8080)
- Backend API: [http://your-ec2-public-ip:3000/api/students](http://localhost:3000/api/students)

---

## 📘 D. What This Setup Includes

- **MySQL DB**: initialized with a SQL script and mounted volume
- **Node.js Backend**: connects to DB using service name `mysql`
- **Frontend**: served on port 8080
- **Health Checks**: waits for MySQL to become healthy
- **Auto-Restart**: all services restart automatically if they crash

---

## 🧪 E. Task for Today

- ✅ Clone this repo or recreate this setup
- ✅ Run the entire app with `docker-compose up`
- ✅ Try breaking a container and restarting it
- ✅ Modify your backend/frontend and rebuild containers using `--build`

---

## ✅ Outcome

By end of Day 6, you can:
- ✅ Define multi-service apps using `docker-compose.yml`
- ✅ Build images from Dockerfiles and manage them
- ✅ Connect services over Compose networks
- ✅ Use health checks, volumes, and environment configs
- ✅ Handle restarts and troubleshooting in multi-container apps

---

## ⏭️ Up Next:  Day 7 – CI/CD Pipeline using Jenkins!
