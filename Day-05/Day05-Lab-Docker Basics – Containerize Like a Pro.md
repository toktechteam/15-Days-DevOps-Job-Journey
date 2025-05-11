
# 🐳 Day 5: Docker Basics – Containerize Like a Pro

Welcome to Day 5 of your DevOps Bootcamp. Today we’ll take our first big leap into the world of **Docker** — from installation to hands-on real-world usage.

---

## 🧠 A. What is Docker?

Docker is a platform that allows you to **package**, **ship**, and **run** applications in lightweight containers.

> No more “it works on my machine.” With Docker, it works the same **everywhere**.

---

## 🌍 B. Real-World Use Case

Imagine your app works locally but crashes in the cloud because of version mismatches, missing packages, or OS differences.  
**Docker solves this** by wrapping your app, config, and dependencies into one container.

---

## 📦 C. Core Docker Concepts

| Term          | Meaning                                                    |
|---------------|------------------------------------------------------------|
| Image         | Blueprint of your app                                      |
| Container     | A running instance of an image                             |
| Dockerfile    | Script with build instructions for the image               |
| Volume        | Persistent storage for data between container restarts     |
| Network       | Virtual bridge between containers to communicate securely  |
| Docker Hub    | Public registry of prebuilt images                         |



---

## 🛠️ D. Step-by-Step Docker Setup

### ✅ Click “Launch Instance”

| Setting              | Value                                                       |
|----------------------|-------------------------------------------------------------|
| Name                 | devops-day05                                                |
| OS                   | Ubuntu Server 24.04, SSD Volume Type, ami-075686beab831bb7f |
| Instance type        | t2.micro                                                    |
| Key pair             | Create new, download `.pem` file                            |
| Security group       | Allow SSH (22), HTTP (80), Custom Port (8080, 3000)         |

Launch and Connect via SSH

```bash
chmod 400 your-key.pem
ssh -i your-key.pem ubuntu@<your-ec2-public-ip>

```

### ✅ Install Docker

**Ubuntu**:
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

**Verify Installation**:
```bash
docker --version
```

---

### ✅ Your First Dockerfile

```Dockerfile
FROM ubuntu
RUN apt update && apt install -y nginx
CMD ["nginx", "-g", "daemon off;"]
```

Save this as `Dockerfile`

---

### ✅ Build & Run the Image

```bash
docker build -t my-nginx .
docker run -d -p 8080:80 my-nginx
```

Now visit: `http://localhost:8080`

---

## 💡 E. Beginner-to-Pro Docker Commands

### 🐳 Basic Commands

```bash
docker ps             # List running containers
docker ps -a          # List all containers
docker images         # List images
docker stop <id>      # Stop a container
docker rm <id>        # Remove container
docker rmi <id>       # Remove image
```

---

### 🧾 Run Containers with Name and Volume

```bash
docker run -d --name webserver -p 8080:80 nginx
```

Add a volume:
```bash
docker run -d --name web-vol -p 8081:80 -v $(pwd)/html:/usr/share/nginx/html nginx
```

Now any files in `./html` on your host will appear inside the container.

---

### 🔓 Exec & Shell Access

```bash
docker exec -it <container_id> bash      # Open bash shell
```

This lets you debug or inspect a running container.

---


---
### 📁 Copy Files In/Out of Container

```bash
docker cp ./file.txt <container_id>:/tmp/file.txt     # Copy into container

Verify : docker exec -it <container_id> /bin/bash

docker cp <container_id>:/tmp/file.txt ./file-copy.txt # Copy from container

```

---

## 🌐 F. Docker Networking

By default, Docker uses a **bridge** network.

### List Networks
```bash
docker network ls
```

### Create Custom Network
```bash
docker network create mynet
```

### Run Containers in Same Network
```bash
  # Create a dockerfile with below content & Crete Docker Image.

FROM python:3.9-slim
WORKDIR /app
CMD ["python3", "-m", "http.server", "8080"]
```

```bash
docker build -t simple-python-server .

```

```bash
docker run -d --name myserver -p 8080:8080 --network mynet simple-python-server 
docker run -d --name app -p 80:80 --network mynet my-app-image
```

Now `app` can talk to `myserver` using the name `myserver`.

---

## 🧹 G. Clean-up Commands

```bash
docker system prune -f             # Remove all stopped containers/images
docker volume ls                   # List volumes
docker volume rm <vol>             # Delete a volume
docker network prune               # Clean unused networks
```

---

## 🎯 Task for Today

- ✅ Create & run NGINX container
- ✅ Add your own HTML page
- ✅ Practice naming, volume mounting, port mapping
- ✅ Create custom networks and test inter-container communication
- ✅ Use `docker cp`, `docker exec` for file access and debugging

---

## ✅ Outcome

By end of Day 5, you will:
- ✅ Understand Docker core concepts
- ✅ Build and run custom containers
- ✅ Use networks, volumes, and shared folders
- ✅ Copy files in/out of containers
- ✅ Access container shell and logs
- ✅ Be ready to build multi-container apps with Docker Compose

---

## ⏭️ Up Next: Day 6 – Launch this setup to a live AWS EC2 Server!
