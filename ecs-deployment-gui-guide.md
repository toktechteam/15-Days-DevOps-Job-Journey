# ECS Deployment Guide - AWS Console (GUI) Version

## Session Overview (Adjusted for 1 hour + 15 min)
- **Duration**: 75 minutes total
- **Format**: Quick theory (10 min) + GUI-based hands-on (65 min)
- **Prerequisites**: AWS Account, Docker Desktop installed

---

## Part 1: Quick Introduction (10 minutes)

### What We'll Build Today
A containerized Node.js application deployed on AWS ECS with:
- Docker image stored in ECR
- Load balancer for high availability
- Auto-scaling for handling traffic
- Health monitoring

### Architecture Components
```
Your App → Docker Image → ECR → ECS Service → Load Balancer → Users
                                      ↓
                                Auto-scaling
```

---

## Part 2: Prepare Sample Application (5 minutes)

### Quick Setup - Copy these 3 files:

**1. app.js**
```javascript
const express = require('express');
const os = require('os');
const app = express();
const PORT = 3000;

app.get('/', (req, res) => {
    res.json({
        message: 'Hello from ECS!',
        container: os.hostname(),
        time: new Date().toISOString()
    });
});

app.get('/health', (req, res) => {
    res.status(200).json({ status: 'healthy' });
});

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
```

**2. package.json**
```json
{
  "name": "ecs-demo",
  "version": "1.0.0",
  "main": "app.js",
  "scripts": {
    "start": "node app.js"
  },
  "dependencies": {
    "express": "^4.18.0"
  }
}
```

**3. Dockerfile**
```dockerfile
FROM node:16-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
```

### Build Docker Image Locally
```bash
# Test locally first
docker build -t ecs-demo .
docker run -p 3000:3000 ecs-demo

# Test in browser: http://localhost:3000
```

---

## Part 3: Step-by-Step AWS Console Guide (60 minutes)

### Step 1: Create ECR Repository (5 minutes)

1. **Navigate to ECR**
   - Open AWS Console → Search "ECR" → Click "Elastic Container Registry"

2. **Create Repository**
   - Click "Create repository" button
   - **Repository name**: `ecs-demo-app`
   - **Scan on push**: Enable (optional)
   - Leave other settings as default
   - Click "Create repository"

3. **Push Commands**
   - Click on your repository name
   - Click "View push commands" button
   - **Copy all 4 commands** (we'll use them next)

### Step 2: Push Docker Image to ECR (5 minutes)

1. **Open Terminal/Command Prompt**
   - Navigate to your application folder
   - Run the 4 commands from ECR (one by one):

```bash
# Command 1: Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin [your-account-id].dkr.ecr.us-east-1.amazonaws.com

# Command 2: Build image
docker build -t ecs-demo-app .

# Command 3: Tag image
docker tag ecs-demo-app:latest [your-account-id].dkr.ecr.us-east-1.amazonaws.com/ecs-demo-app:latest

# Command 4: Push image
docker push [your-account-id].dkr.ecr.us-east-1.amazonaws.com/ecs-demo-app:latest
```

2. **Verify Upload**
   - Refresh ECR repository page
   - You should see "latest" tag with size info

### Step 3: Create ECS Cluster (3 minutes)

1. **Navigate to ECS**
   - AWS Console → Search "ECS" → Click "Elastic Container Service"

2. **Create Cluster**
   - Click "Create cluster"
   - **Cluster name**: `ecs-demo-cluster`
   - **Infrastructure**: Select "AWS Fargate (serverless)"
   - Click "Create"

### Step 4: Create Task Definition (7 minutes)

1. **Go to Task Definitions**
   - Left menu → Click "Task definitions"
   - Click "Create new task definition"

2. **Configure Task**
   - **Task definition family**: `ecs-demo-task`
   - **Launch type**: Select "AWS Fargate"
   - **Operating system**: Linux
   - **CPU**: 0.25 vCPU
   - **Memory**: 0.5 GB
   - **Task role**: None (for now)
   - **Task execution role**: Create new role (or select existing)

3. **Add Container**
   - Click "Add container"
   - **Container name**: `ecs-demo-app`
   - **Image URI**: Copy from ECR (click "Copy URI" in ECR)
   - **Port mappings**: 
     - Container port: `3000`
     - Protocol: TCP
   - **Essential**: Check ✓
   - Click "Add"

4. **Create Task Definition**
   - Review settings
   - Click "Create"

### Step 5: Create Application Load Balancer (10 minutes)

1. **Navigate to EC2**
   - AWS Console → EC2 → Load Balancers (left menu)

2. **Create Load Balancer**
   - Click "Create load balancer"
   - Choose "Application Load Balancer"
   - **Name**: `ecs-demo-alb`
   - **Scheme**: Internet-facing
   - **IP address type**: IPv4

3. **Network Mapping**
   - **VPC**: Select default VPC
   - **Availability Zones**: Select at least 2 AZs
   - Select one subnet per AZ

4. **Security Group**
   - Click "Create new security group"
   - **Name**: `ecs-alb-sg`
   - **Inbound rules**: 
     - Type: HTTP
     - Port: 80
     - Source: Anywhere (0.0.0.0/0)
   - Create security group
   - Return to ALB creation and select this SG

5. **Target Group**
   - **Target type**: IP addresses
   - **Target group name**: `ecs-demo-targets`
   - **Protocol**: HTTP
   - **Port**: 3000
   - **Health check path**: `/health`
   - **Health check interval**: 30 seconds

6. **Review and Create**
   - Review all settings
   - Click "Create load balancer"
   - Note down the DNS name

**⚠️ IMPORTANT**: Do NOT manually register any targets in the target group. Leave it empty for now. The ECS service will automatically register/deregister container IPs as targets when we create the service in Step 6.

### Step 6: Create ECS Service (10 minutes)

1. **Go Back to ECS**
   - Navigate to your cluster
   - Click on "ecs-demo-cluster"

2. **Create Service**
   - In Services tab, click "Create"
   - **Launch type**: FARGATE
   - **Task definition**: Select `ecs-demo-task`
   - **Service name**: `ecs-demo-service`
   - **Number of tasks**: 2

3. **Network Configuration**
   - **Cluster VPC**: Select default VPC
   - **Subnets**: Select same subnets as ALB (ensure these are PUBLIC subnets with internet gateway route)
   - **Security group**: Select existing `ecs-tasks-sg`
   - **Auto-assign public IP**: **ENABLED** ← CRITICAL: Must be enabled for ECR access
   
   ⚠️ **Important**: If you see "ResourceInitializationError" later, it's usually because public IP is disabled or using private subnets without VPC endpoints.

4. **Load Balancing**
   - **Load balancer type**: Application Load Balancer
   - **Load balancer**: Select `ecs-demo-alb`
   - **Container to load balance**: Select `ecs-demo-app:3000`
   - **Target group**: Select `ecs-demo-targets`

5. **Create Service**
   - Review and click "Create service"
   - Wait for tasks to start (2-3 minutes)

### Step 7: Configure Auto-scaling (5 minutes)

1. **In Service Page**
   - Click on your service name
   - Go to "Auto Scaling" tab
   - Click "Update"

2. **Configure Scaling**
   - **Minimum tasks**: 2
   - **Desired tasks**: 2
   - **Maximum tasks**: 10

3. **Add Scaling Policy**
   - Click "Add scaling policy"
   - **Policy type**: Target tracking
   - **Policy name**: `cpu-scaling-policy`
   - **ECS service metric**: Average CPU utilization
   - **Target value**: 70
   - Click "Save"

### Step 8: Test Your Application (5 minutes)

1. **Get ALB DNS**
   - EC2 → Load Balancers
   - Select your ALB
   - Copy DNS name

2. **Verify Target Group Health**
   - EC2 → Target Groups
   - Select `ecs-demo-targets`
   - Click "Targets" tab
   - You should see 2 healthy targets (IPs) automatically registered by ECS
   - If unhealthy, wait 1-2 minutes for health checks to pass

3. **Test in Browser**
   ```
   http://[your-alb-dns-name]
   http://[your-alb-dns-name]/health
   ```

4. **Check ECS Console**
   - View running tasks
   - Check service events
   - Monitor health status

### Step 9: Test Auto-scaling (Optional - 5 minutes)

1. **Generate Load to Trigger Scaling**
   ```bash
   # Open terminal/command prompt
   # Replace with your ALB DNS name
   export ALB_DNS="your-alb-dns-name"
   
   # Generate load (run this command)
   for i in {1..1000}; do curl http://$ALB_DNS & done
   
   # Or use this alternative approach:
   while true; do curl http://$ALB_DNS; done
   ```

2. **Monitor Auto-scaling**
   - ECS → Your cluster → Your service
   - **Metrics tab**: Watch CPU utilization climb
   - **Tasks tab**: See new tasks launching (3, 4, 5...)
   - **Events tab**: See scaling activities

3. **Check CloudWatch**
   - CloudWatch → Metrics → ECS
   - Select your cluster/service
   - View CPU utilization graph

4. **Stop the Load Test**
   - Press `Ctrl+C` in terminal
   - Wait 2-3 minutes
   - Watch tasks scale back down to 2

---

## Part 4: Monitoring and Troubleshooting (10 minutes)

### View Logs in CloudWatch

1. **Navigate to CloudWatch**
   - AWS Console → CloudWatch
   - Left menu → Logs → Log groups

2. **Find Your Logs**
   - Look for `/ecs/ecs-demo-task`
   - Click on log streams
   - View application logs

### How ECS Service Manages Targets

**Automatic Target Registration Process:**
1. When ECS service starts a task → Container gets an IP
2. ECS automatically registers this IP in the target group
3. ALB starts health checks on the new target
4. Once healthy, traffic is routed to the container
5. When task stops → ECS automatically deregisters the IP

**What You'll See:**
- **Before creating service**: Target group shows "0 targets"
- **After creating service**: Target group shows IPs of running containers
- **During scaling**: New IPs appear/disappear automatically

### Common Issues and Solutions

| Issue | Solution |
|-------|----------|
| Tasks not starting | Check CloudWatch logs, verify IAM roles |
| Unhealthy targets | Check security groups, health check path |
| Cannot access app | Verify ALB security group allows port 80 |
| Image pull error | Check ECR permissions, image URI |
| ResourceInitializationError | 1. Enable auto-assign public IP<br>2. **Check outbound rules in task security group (must allow all traffic to 0.0.0.0/0)**<br>3. Verify task execution role exists |

### Update Your Application

1. **Make Code Changes**
2. **Build New Image**
3. **Push to ECR with new tag**
4. **Update Task Definition** (create new revision)
5. **Update Service** (it will do rolling deployment)

---

## Quick Reference - Console Navigation

```
ECR: Console → ECR → Repositories
ECS: Console → ECS → Clusters/Task Definitions/Services  
ALB: Console → EC2 → Load Balancers
Security Groups: Console → EC2 → Security Groups
CloudWatch: Console → CloudWatch → Logs
```

---

## Clean-up After Session

1. **ECS Service**: Update to 0 tasks, then delete
2. **ALB**: Delete from EC2 console
3. **Target Group**: Delete after ALB
4. **Task Definition**: Deregister
5. **ECR Repository**: Delete (force delete if needed)
6. **Security Groups**: Delete (remove dependencies first)
7. **CloudWatch Logs**: Delete log group

---

## Key Takeaways

✅ ECR stores your Docker images securely  
✅ ECS runs your containers without managing servers  
✅ ALB distributes traffic across containers  
✅ Auto-scaling handles traffic spikes automatically  
✅ CloudWatch provides logs and monitoring  

## Next Steps
- Try deploying a multi-container application
- Explore ECS with EC2 launch type
- Learn about AWS App Runner (even simpler!)
- Implement CI/CD with CodePipeline
