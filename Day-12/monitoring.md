# 🌍 Day 12: Monitoring with Prometheus + Grafana

Welcome to Day 12 of your DevOps Bootcamp!
Today you'll learn why **monitoring** is crucial after deployment — and how to set up a real-world monitoring stack using **Prometheus** and **Grafana** with Docker Compose.

---

# 🎯 Why Monitoring Matters

DevOps doesn’t stop at deployment — you must track how your application behaves in real-time:

- 🌐 CPU/RAM usage
- ✅ App uptime
- ⚠️ Service errors
- ⏳ Request counts & response times

> Without monitoring, you’re blind to failures until your users complain!

---

# 🔍 What Prometheus + Grafana Do

| Tool         | Purpose                            |
|--------------|-------------------------------------|
| Prometheus   | Collects metrics from services      |
| Grafana      | Visualizes that data beautifully     |

Together they form the most popular **open-source monitoring stack** used by startups and enterprises.

---
## 📦 B. Quick Start: Compose a Simple Setup

### ✅ Click “Launch Instance”

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
### Install Docker & Docker-Compose

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




---
# 🛠 Hands-On: Run Monitoring Stack with Docker Compose

### ✅ Step 1: Create a New Directory
```bash
mkdir monitoring && cd monitoring
```

### ✅ Step 2: Create `docker-compose.yml`
```yaml
version: '3'
services:
  prometheus:
    image: prom/prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml

  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
```

### ✅ Step 3: Create `prometheus.yml`
```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
```

### ✅ Step 4: Run the Stack
```bash
docker-compose up -d
```

---
### ✅ Docker will pull Prometheus and Grafana images, configure them, and start them in detached mode.

#### 🚀 Access Your Monitoring Tools

| Service      | URL                                  |
|--------------|--------------------------------------|
| Prometheus   | http://localhost:9090                 |
| Grafana      | http://localhost:3000                 |

### Login to Grafana:
- Username: **admin**
- Password: **admin** (change after first login!)

### In Grafana:
- Add **Prometheus** as a **Data Source**
- Create a **basic dashboard panel** showing metrics like `up` status.

#### Configure Grafana Dashboards
After starting your updated setup, follow these steps to create dashboards in Grafana:

1. Access Grafana at http://your-ec2-ip:3001
2. Log in with default credentials (admin/admin)
3. Add Prometheus as a data source:
  - Go to Configuration > Data Sources > Add data source
  - Select Prometheus
  - Set URL to http://prometheus:9090
  - Click "Save & Test"

4. Import pre-made dashboards for Node Exporter and cAdvisor:
   - Go to Create > Import
   - Use these dashboard IDs:
      - 1860 for Node Exporter Full dashboard
      - 193 for Docker monitoring dashboard

---

# 🧪 Lab Task for You

✅ Setup Prometheus + Grafana stack using Docker Compose  
✅ Access both dashboards  
✅ Add Prometheus as a data source in Grafana  
✅ Create at least **one custom dashboard panel**

---

# ✅ Outcome by End of Day 12

- Deploy a real-time monitoring stack easily
- Understand how Prometheus scrapes metrics
- Visualize real metrics with Grafana dashboards
- Prepare yourself for production-grade monitoring setups

---

# 📢 Next Up: Day 13 — Resume Building + DevOps Portfolio Creation!

We’ll switch gears from hands-on labs to building your personal DevOps brand ✨

---

# ✅ Testing Status

- Code tested on local Docker Desktop ✅
- Prometheus and Grafana accessible via localhost ✅
- Dashboard created and functional ✅

---
