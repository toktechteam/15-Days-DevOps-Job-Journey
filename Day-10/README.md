# Day-10: Continuous Deployment (CD) Pipeline

Simple Jenkins CD pipeline that deploys student management application to dev, qa, and staging environments using Docker Compose.

## 🏗️ Architecture

```
EC2 Instance
├── Jenkins Container (Port 8081) - Day-09 Setup
└── Student App Environments:
    ├── DEV (MySQL: 3306, Backend: 3000, Frontend: 8080)
    ├── QA (MySQL: 3307, Backend: 3001, Frontend: 8082)  
    └── STAGING (MySQL: 3308, Backend: 3002, Frontend: 8083)
```

## 🚀 Quick Setup

### 1. Add Docker Compose Files
Add these files to your `Day-09/docker/` folder:
- `docker-compose-dev.yml`
- `docker-compose-qa.yml`
- `docker-compose-staging.yml`

### 2. First-Time Manual Setup
Run once per environment:

```bash
cd Day-09/docker

# DEV Environment
docker-compose -f docker-compose-dev.yml up -d mysql
sleep 30
docker-compose -f docker-compose-dev.yml up -d

# QA Environment
docker-compose -f docker-compose-qa.yml up -d mysql
sleep 30  
docker-compose -f docker-compose-qa.yml up -d

# STAGING Environment
docker-compose -f docker-compose-staging.yml up -d mysql
sleep 30
docker-compose -f docker-compose-staging.yml up -d
```

### 3. Create Jenkins Job
1. Open Jenkins (Port 8081) - use your existing Day-09 setup
2. Create **New Item** → **Pipeline**
3. **Pipeline Definition**: Pipeline script from SCM
4. **Repository URL**: Your Day-09 repository
5. **Script Path**: `Jenkinsfile` (add to root of your repo)

## 🎯 Pipeline Features

- **Environment Selection**: Choose dev/qa/staging
- **Image Tag Selection**: Deploy specific versions
- **Zero Database Downtime**: Only restarts app containers
- **Health Checks**: Verifies deployment success
- **Smoke Tests**: Basic API testing

## 📊 Environment Ports

| Environment | Frontend URL | Backend API URL | Database Port |
|-------------|--------------|-----------------|---------------|
| **DEV**     | :8080        | :3000           | 3306          |
| **QA**      | :8082        | :3001           | 3307          |  
| **STAGING** | :8083        | :3002           | 3308          |

## 🚀 How to Deploy

1. **Open Jenkins** → Your CD Pipeline Job
2. **Build with Parameters**:
    - Environment: dev/qa/staging
    - Backend Tag: latest (or specific version)
    - Frontend Tag: latest (or specific version)
    - Skip Tests: false
3. **Click Build**

## 🛠️ Troubleshooting

### Check Container Status
```bash
cd Day-09/docker

# Check specific environment
docker-compose -f docker-compose-dev.yml ps
docker-compose -f docker-compose-qa.yml ps
docker-compose -f docker-compose-staging.yml ps
```

### View Logs
```bash
# All services
docker-compose -f docker-compose-dev.yml logs -f

# Specific service
docker-compose -f docker-compose-dev.yml logs backend
```

### Restart Services
```bash
# Restart app only (keep DB running)
docker-compose -f docker-compose-dev.yml restart frontend backend

# Restart everything
docker-compose -f docker-compose-dev.yml restart
```

### Stop Environment
```bash
# Stop specific environment
docker-compose -f docker-compose-dev.yml down

# Stop only app containers
docker-compose -f docker-compose-dev.yml stop frontend backend
```

### Database Access
```bash
# DEV database
docker exec -it student-management-db-dev mysql -u root -proot_password

# QA database  
docker exec -it student-management-db-qa mysql -u root -proot_password

# STAGING database
docker exec -it student-management-db-staging mysql -u root -proot_password
```

## 🔄 Workflow

```
Day-09 CI → Builds Images → Pushes to Docker Hub
Day-10 CD → Pulls Images → Updates Compose → Deploys
```

## 📁 Repository Structure

```
Day-09/
├── src/                          # Application code  
├── docker/
│   ├── Dockerfile.backend
│   ├── Dockerfile.frontend
│   ├── docker-compose.yml        # Original
│   ├── docker-compose-dev.yml    # DEV environment
│   ├── docker-compose-qa.yml     # QA environment
│   ├── docker-compose-staging.yml # STAGING environment
│   └── setup_script.sh
├── Jenkinsfile                   # CD Pipeline (add this)
└── README.md                     # This file
```

---

**Ready to deploy! 🚀 Uses your existing Day-09 Jenkins setup.**