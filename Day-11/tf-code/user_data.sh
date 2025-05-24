#!/bin/bash

exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "=== Starting TheOpsKart EC2 App Setup ==="
yum update -y

echo "=== Installing Docker and Git ==="
yum install -y docker git
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user

echo "=== Setting Up Application ==="
mkdir -p /home/ec2-user/theopskart-app
cd /home/ec2-user/theopskart-app

cat > package.json << 'EOF'
{
  "name": "theopskart-ec2-app",
  "version": "1.0.0",
  "main": "server.js",
  "dependencies": {
    "express": "^4.18.2"
  },
  "scripts": {
    "start": "node server.js"
  }
}
EOF

cat > server.js << 'EOF'
const express = require('express');
const os = require('os');

const app = express();
const PORT = 3000;

app.use(express.static('public'));

app.get('/api/info', (req, res) => {
  res.json({
    message: 'Hello from Terraform EC2 Instance! This is Day-11 Session Happy Learning with TheOpskart',
    hostname: os.hostname(),
    platform: os.platform(),
    timestamp: new Date().toISOString()
  });
});

app.listen(PORT, () => {
  console.log(`✅ App running at http://localhost:${PORT}`);
});
EOF

mkdir -p public
cat > public/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>TheOpsKart EC2</title>
  <style>
    body {
      background-color: #002b5c;
      color: #fff;
      font-family: 'Courier New', monospace;
      display: flex;
      flex-direction: column;
      justify-content: center;
      align-items: center;
      height: 100vh;
      margin: 0;
    }
    .message {
      font-size: 1.6rem;
      animation: fadeIn 1.5s ease-in-out;
    }
    .table-container {
      background-color: #003f88;
      padding: 20px;
      border-radius: 8px;
      margin-top: 20px;
      font-size: 1rem;
      min-width: 400px;
    }
    table {
      width: 100%;
      border-collapse: collapse;
    }
    td {
      padding: 8px 12px;
      border-bottom: 1px solid #0050c1;
    }
    td:first-child {
      font-weight: bold;
      color: #99ccff;
      width: 40%;
    }
    @keyframes fadeIn {
      from { opacity: 0; }
      to { opacity: 1; }
    }
  </style>
</head>
<body>
  <div class="message">🚀 TheOpsKart EC2 is Live!</div>
  <div class="table-container">
    <table id="infoTable">
      <tr><td>Message</td><td>Loading...</td></tr>
      <tr><td>Hostname</td><td>Loading...</td></tr>
      <tr><td>Platform</td><td>Loading...</td></tr>
      <tr><td>Timestamp</td><td>Loading...</td></tr>
    </table>
  </div>

  <script>
    fetch('/api/info')
      .then(res => res.json())
      .then(data => {
        const table = document.getElementById("infoTable");
        table.innerHTML = `
          <tr><td>Message</td><td>${data.message}</td></tr>
          <tr><td>Hostname</td><td>${data.hostname}</td></tr>
          <tr><td>Platform</td><td>${data.platform}</td></tr>
          <tr><td>Timestamp</td><td>${new Date(data.timestamp).toLocaleString()}</td></tr>
        `;
      })
      .catch(() => {
        document.querySelector('.table-container').textContent = '❌ Failed to load server info.';
      });
  </script>
</body>
</html>
EOF

cat > Dockerfile << 'EOF'
FROM node:18-alpine
WORKDIR /app
COPY . .
RUN npm install
EXPOSE 3000
CMD ["npm", "start"]
EOF

echo "=== Building and Running Docker Container ==="
docker build -t theopskart-app .
docker run -d -p 3000:3000 --name theopskart theopskart-app

echo "🎉 App is live at port 3000!"
echo "🌐 Visit: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):3000"
