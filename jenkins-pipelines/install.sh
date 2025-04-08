#!/bin/bash

echo "🔧 Creating Docker network..."
docker network create jenkins 2>/dev/null || echo "⚠️  Network already exists"

echo "🚀 Starting Jenkins container..."
docker run -d --name jenkins \
  --restart unless-stopped \
  -p 8081:8080 -p 50000:50000 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v jenkins_home:/var/jenkins_home \
  --network jenkins \
  jenkins/jenkins:lts

echo "⏳ Waiting for Jenkins to initialize..."
sleep 15

echo "🔐 Jenkins initial admin password:"
docker exec -it jenkins cat /var/jenkins_home/secrets/initialAdminPassword

