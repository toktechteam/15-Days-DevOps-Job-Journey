# Session 4: Deploying Docker Containers to ECS

## Session Overview (5 minutes)
- **Duration**: 90-120 minutes
- **Format**: 20% Theory, 80% Hands-on
- **Prerequisites**: AWS Account, Docker installed, AWS CLI configured

---

## Part 1: Introduction to ECS & ECR (15 minutes)

### What is Amazon ECS?
- **Elastic Container Service**: Fully managed container orchestration service
- **Key Components**:
  - **Clusters**: Logical grouping of tasks or services
  - **Task Definitions**: Blueprint for your application
  - **Tasks**: Running instance of a task definition
  - **Services**: Manages desired number of tasks

### What is Amazon ECR?
- **Elastic Container Registry**: Fully managed Docker container registry
- **Benefits**: Integrated with ECS, secure, scalable, highly available

### Architecture Overview
```
Developer → Docker Image → ECR → ECS Task Definition → ECS Service → ALB → Users
```

---

## Part 2: Sample Application Setup (10 minutes)

### Create a Simple Node.js Application

**app.js**:
```javascript
const express = require('express');
const os = require('os');
const app = express();
const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
    res.json({
        message: 'Hello from ECS!',
        hostname: os.hostname(),
        platform: os.platform(),
        uptime: process.uptime(),
        timestamp: new Date().toISOString()
    });
});

app.get('/health', (req, res) => {
    res.status(200).json({ status: 'healthy' });
});

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
```

**package.json**:
```json
{
  "name": "ecs-demo-app",
  "version": "1.0.0",
  "description": "Demo app for ECS deployment",
  "main": "app.js",
  "scripts": {
    "start": "node app.js"
  },
  "dependencies": {
    "express": "^4.18.0"
  }
}
```

**Dockerfile**:
```dockerfile
FROM node:16-alpine

WORKDIR /usr/src/app

COPY package*.json ./
RUN npm ci --only=production

COPY . .

EXPOSE 3000

CMD ["node", "app.js"]
```

---

## Part 3: Hands-on Lab - Step by Step (60 minutes)

### Lab 1: Setting up AWS ECR (10 minutes)

#### 1.1 Create ECR Repository
```bash
# Set variables
export AWS_REGION=us-east-1
export REPO_NAME=ecs-demo-app
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Create ECR repository
aws ecr create-repository \
    --repository-name $REPO_NAME \
    --region $AWS_REGION
```

#### 1.2 Get Login Token
```bash
# Authenticate Docker to ECR
aws ecr get-login-password --region $AWS_REGION | \
docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
```

### Lab 2: Build and Push Docker Image to ECR (10 minutes)

#### 2.1 Build Docker Image
```bash
# Build the Docker image
docker build -t $REPO_NAME:latest .

# Verify image
docker images | grep $REPO_NAME
```

#### 2.2 Tag and Push to ECR
```bash
# Tag the image for ECR
docker tag $REPO_NAME:latest \
$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:latest

# Push to ECR
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:latest

# Verify push
aws ecr describe-images --repository-name $REPO_NAME --region $AWS_REGION
```

### Lab 3: Create ECS Cluster (5 minutes)

```bash
# Create ECS cluster
aws ecs create-cluster --cluster-name ecs-demo-cluster

# Verify cluster creation
aws ecs describe-clusters --clusters ecs-demo-cluster
```

### Lab 4: Create Task Definition (10 minutes)

Create file **task-definition.json**:
```json
{
    "family": "ecs-demo-task",
    "networkMode": "awsvpc",
    "requiresCompatibilities": ["FARGATE"],
    "cpu": "256",
    "memory": "512",
    "containerDefinitions": [
        {
            "name": "ecs-demo-app",
            "image": "YOUR_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/ecs-demo-app:latest",
            "portMappings": [
                {
                    "containerPort": 3000,
                    "protocol": "tcp"
                }
            ],
            "essential": true,
            "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-group": "/ecs/ecs-demo-app",
                    "awslogs-region": "us-east-1",
                    "awslogs-stream-prefix": "ecs"
                }
            }
        }
    ],
    "executionRoleArn": "arn:aws:iam::YOUR_ACCOUNT_ID:role/ecsTaskExecutionRole"
}
```

#### Create CloudWatch Log Group
```bash
aws logs create-log-group --log-group-name /ecs/ecs-demo-app
```

#### Register Task Definition
```bash
# Replace YOUR_ACCOUNT_ID in task-definition.json first
sed -i "s/YOUR_ACCOUNT_ID/$AWS_ACCOUNT_ID/g" task-definition.json

# Register task definition
aws ecs register-task-definition --cli-input-json file://task-definition.json
```

### Lab 5: Set up Application Load Balancer (10 minutes)

#### 5.1 Create Security Groups
```bash
# ALB Security Group
aws ec2 create-security-group \
    --group-name ecs-alb-sg \
    --description "Security group for ECS ALB" \
    --vpc-id $(aws ec2 describe-vpcs --query 'Vpcs[0].VpcId' --output text)

# Get ALB SG ID
export ALB_SG_ID=$(aws ec2 describe-security-groups \
    --group-names ecs-alb-sg \
    --query 'SecurityGroups[0].GroupId' \
    --output text)

# Allow HTTP traffic
aws ec2 authorize-security-group-ingress \
    --group-id $ALB_SG_ID \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0

# ECS Tasks Security Group
aws ec2 create-security-group \
    --group-name ecs-tasks-sg \
    --description "Security group for ECS tasks"

export TASK_SG_ID=$(aws ec2 describe-security-groups \
    --group-names ecs-tasks-sg \
    --query 'SecurityGroups[0].GroupId' \
    --output text)

# Allow traffic from ALB
aws ec2 authorize-security-group-ingress \
    --group-id $TASK_SG_ID \
    --protocol tcp \
    --port 3000 \
    --source-group $ALB_SG_ID
```

#### 5.2 Create Application Load Balancer
```bash
# Get subnet IDs (requires at least 2 subnets)
export SUBNET_1=$(aws ec2 describe-subnets --query 'Subnets[0].SubnetId' --output text)
export SUBNET_2=$(aws ec2 describe-subnets --query 'Subnets[1].SubnetId' --output text)

# Create ALB
aws elbv2 create-load-balancer \
    --name ecs-demo-alb \
    --subnets $SUBNET_1 $SUBNET_2 \
    --security-groups $ALB_SG_ID

# Get ALB ARN
export ALB_ARN=$(aws elbv2 describe-load-balancers \
    --names ecs-demo-alb \
    --query 'LoadBalancers[0].LoadBalancerArn' \
    --output text)
```

#### 5.3 Create Target Group
```bash
# Get VPC ID
export VPC_ID=$(aws ec2 describe-vpcs --query 'Vpcs[0].VpcId' --output text)

# Create target group
aws elbv2 create-target-group \
    --name ecs-demo-targets \
    --protocol HTTP \
    --port 3000 \
    --vpc-id $VPC_ID \
    --target-type ip \
    --health-check-path /health

# Get Target Group ARN
export TG_ARN=$(aws elbv2 describe-target-groups \
    --names ecs-demo-targets \
    --query 'TargetGroups[0].TargetGroupArn' \
    --output text)
```

#### 5.4 Create ALB Listener
```bash
aws elbv2 create-listener \
    --load-balancer-arn $ALB_ARN \
    --protocol HTTP \
    --port 80 \
    --default-actions Type=forward,TargetGroupArn=$TG_ARN
```

### Lab 6: Create ECS Service with Auto-scaling (15 minutes)

#### 6.1 Create ECS Service
```bash
# Create service
aws ecs create-service \
    --cluster ecs-demo-cluster \
    --service-name ecs-demo-service \
    --task-definition ecs-demo-task:1 \
    --desired-count 2 \
    --launch-type FARGATE \
    --network-configuration "awsvpcConfiguration={subnets=[$SUBNET_1,$SUBNET_2],securityGroups=[$TASK_SG_ID],assignPublicIp=ENABLED}" \
    --load-balancers targetGroupArn=$TG_ARN,containerName=ecs-demo-app,containerPort=3000
```

#### 6.2 Configure Auto-scaling
```bash
# Register scalable target
aws application-autoscaling register-scalable-target \
    --service-namespace ecs \
    --resource-id service/ecs-demo-cluster/ecs-demo-service \
    --scalable-dimension ecs:service:DesiredCount \
    --min-capacity 2 \
    --max-capacity 10

# Create scaling policy (CPU-based)
aws application-autoscaling put-scaling-policy \
    --service-namespace ecs \
    --scalable-dimension ecs:service:DesiredCount \
    --resource-id service/ecs-demo-cluster/ecs-demo-service \
    --policy-name ecs-cpu-scaling-policy \
    --policy-type TargetTrackingScaling \
    --target-tracking-scaling-policy-configuration '{
        "TargetValue": 70.0,
        "PredefinedMetricSpecification": {
            "PredefinedMetricType": "ECSServiceAverageCPUUtilization"
        },
        "ScaleOutCooldown": 60,
        "ScaleInCooldown": 60
    }'
```

---

## Part 4: Testing and Validation (10 minutes)

### 4.1 Get ALB DNS Name
```bash
# Get ALB DNS
export ALB_DNS=$(aws elbv2 describe-load-balancers \
    --names ecs-demo-alb \
    --query 'LoadBalancers[0].DNSName' \
    --output text)

echo "ALB URL: http://$ALB_DNS"
```

### 4.2 Test the Application
```bash
# Test endpoint
curl http://$ALB_DNS

# Test health check
curl http://$ALB_DNS/health

# Load test for auto-scaling (optional)
for i in {1..1000}; do curl http://$ALB_DNS & done
```

### 4.3 Monitor in AWS Console
- Check ECS cluster for running tasks
- Monitor CloudWatch metrics
- Verify auto-scaling activities

---

## Part 5: Clean-up and Best Practices (5 minutes)

### 5.1 View Service Logs
```bash
# View service events
aws ecs describe-services \
    --cluster ecs-demo-cluster \
    --services ecs-demo-service \
    --query 'services[0].events[:5]'

# View CloudWatch logs
aws logs tail /ecs/ecs-demo-app --follow
```

### 5.2 Update Service (Rolling Deployment)
```bash
# Update task definition and deploy
aws ecs update-service \
    --cluster ecs-demo-cluster \
    --service ecs-demo-service \
    --task-definition ecs-demo-task:2 \
    --desired-count 3
```

### 5.3 Clean-up Resources (Optional)
```bash
# Delete service
aws ecs update-service \
    --cluster ecs-demo-cluster \
    --service ecs-demo-service \
    --desired-count 0

aws ecs delete-service \
    --cluster ecs-demo-cluster \
    --service ecs-demo-service

# Delete ALB
aws elbv2 delete-load-balancer --load-balancer-arn $ALB_ARN

# Delete target group
aws elbv2 delete-target-group --target-group-arn $TG_ARN

# Delete cluster
aws ecs delete-cluster --cluster ecs-demo-cluster

# Delete ECR repository
aws ecr delete-repository \
    --repository-name $REPO_NAME \
    --force
```

---

## Best Practices

1. **Container Image Optimization**
   - Use multi-stage builds
   - Minimize image size
   - Use specific base image versions

2. **Security**
   - Use IAM roles for tasks
   - Store secrets in AWS Secrets Manager
   - Enable VPC endpoints for ECR

3. **Monitoring**
   - Set up CloudWatch alarms
   - Use Container Insights
   - Enable X-Ray for tracing

4. **Cost Optimization**
   - Use Fargate Spot for non-critical workloads
   - Right-size task definitions
   - Use auto-scaling effectively

---

## Q&A and Troubleshooting Tips

### Common Issues:
1. **Task fails to start**: Check CloudWatch logs, verify IAM roles
2. **ALB health checks failing**: Ensure correct port and path
3. **Image pull errors**: Verify ECR permissions and image URI
4. **Auto-scaling not working**: Check CloudWatch metrics and policies

### Additional Resources:
- AWS ECS Documentation
- AWS ECR Best Practices
- Container Insights Dashboard
- AWS Well-Architected Framework

---

## Session Summary
- Deployed containerized application to ECS
- Integrated with ECR for image management
- Configured ALB for load balancing
- Implemented auto-scaling for high availability
- Learned monitoring and troubleshooting basics
