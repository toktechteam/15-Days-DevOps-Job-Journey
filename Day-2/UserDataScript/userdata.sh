#!/bin/bash

# Update package repositories non-interactively
apt-get update -y

# Install Nginx non-interactively
apt-get install -y nginx

# Create custom index.html
cat > /var/www/html/index.html << 'EOL'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>DevOps Journey - Day 02</title>
    <style>
        body {
          background-color: #1e2a38; /* blue-gray shade */
          color: #ffffff;
          font-family: Arial, sans-serif;
          display: flex;
          align-items: center;
          justify-content: center;
          flex-direction: column;
          height: 100vh;
          margin: 0;
          text-align: center;
        }

        .blink {
          font-size: 2.5rem;
          font-weight: bold;
          animation: blinkText 3.2s infinite;
        }

        .info {
          margin-top: 30px;
          font-size: 1.5rem;
          color: #00ffcc;
        }

        @keyframes blinkText {
          0% { opacity: 1; }
          50% { opacity: 0; }
          100% { opacity: 1; }
        }
    </style>
</head>
<body>
<div class="blink">
    Welcome to Day-02 of your DevOps journey,<br />
    Till now you are doing very good work. Keep it up!
</div>
<div class="info">
    🚀 This app is running on an EC2 instance!
</div>
</body>
</html>
EOL

# Set proper permissions
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Restart Nginx to apply changes
systemctl restart nginx

# Enable Nginx to start on boot
systemctl enable nginx