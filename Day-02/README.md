# Student Management System Deployment

## 🧠 A. What is EC2?
Amazon EC2 (Elastic Compute Cloud) provides resizable virtual servers in the cloud.

Why DevOps Engineers Use EC2:
- To host applications and backend services
- To run Docker containers and CI/CD tools
- To automate infrastructure with Terraform or Ansible
- To set up monitoring and logging agents

## 🚀 B. Hands-On: Launch Your First EC2 Instance
✅ 1. Login to AWS Console and Navigate to EC2
https://console.aws.amazon.com/ec2/

✅ 2. Click "Launch Instance"
| Setting | Value |
|---------|-------|
| Name | devops-day02 |
| OS | Ubuntu Server 24.04, SSD Volume Type, ami-0f9de6e2d2f067fca |
| Instance type | t2.micro |
| Key pair | Create new, download .pem file |
| Security group | Allow SSH (22), HTTP (80), Custom Port (8080, 3000) |

✅ 3. Launch and Connect via SSH
```bash
chmod 400 your-key.pem
ssh -i your-key.pem ubuntu@<your-ec2-public-ip>
```

### Bonus Lab: Install and Test Nginx on EC2 -- Do it must

Objective:
Practice installing a real web server and exposing it via EC2 Public IP.
Steps:
✅ Install Nginx
```bash
sudo apt update
sudo apt install nginx -y
```

✅ Allow Port 80 in EC2 Security Group
In AWS EC2 console ➔ Security Groups ➔ Edit inbound rules ➔ Add HTTP (80).

✅ Start Nginx Service
```bash
sudo systemctl start nginx
sudo systemctl enable nginx
```

✅ Test Nginx Access
Open browser:
http://<your-ec2-public-ip>
✅ You should see "Welcome to nginx!" page.

✅ For customize index.html page, Copy Paste the index.html file in your nginx.

```bash
sudo su
cd /var/www/html/
mv index.html index.html_bkp
vim index.html   --> Paste the content here which is given.
systemctl status nginx
```

### Automating Nginx Setup with User Data (Alternative Approach)

After understanding the manual installation process, you can automate this using an EC2 User Data script:

1. In the EC2 launch wizard, expand the "Advanced details" section
2. Scroll down to the "User data" text area
3. Copy the contents from `UserDataScript/userdata.sh` in this repository
4. Paste it into the User Data field
5. Complete your instance launch
6. Wait 3-5 minutes for the script to execute during instance initialization
7. Access your EC2 public IP in a browser to see your custom page automatically deployed

Note: This automated approach performs the same steps as the manual installation, but saves time for repeated deployments.

## 🔧 C. Prepare EC2 Environment
Update and install required software:

```bash
sudo apt update -y
sudo apt install -y nodejs npm git python3-pip
sudo apt install net-tools
sudo apt install mysql-server -y
```

Start MySQL and secure it:

```bash
sudo systemctl start mysql
sudo mysql_secure_installation
sudo mysql
```

1. Then run the following to switch root to password auth:
```sql
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'your_new_password';
FLUSH PRIVILEGES;
```

## 📦 D. Clone the App from GitHub
✅ 1. Clone the Repository
```bash
git clone https://github.com/YOUR-USERNAME/student-management-system.git
cd student-management-system
```
Replace YOUR-USERNAME with your actual GitHub account

## 🗃️ E. Database Setup
✅ 1. Login to MySQL
```bash
sudo mysql -u root -p
```
Default Password: root

Paste the SQL setup via CLI:

```bash
mysql -u root -p < database/setup.sql
```
Better to create app user in your DB and assign permission to that user.

```sql
CREATE USER 'appuser'@'localhost' IDENTIFIED BY 'app_password';
GRANT ALL PRIVILEGES ON your_database.* TO 'appuser'@'localhost';
FLUSH PRIVILEGES;

GRANT CREATE, DROP, SELECT, INSERT, UPDATE, DELETE ON *.* TO 'appuser'@'localhost';
FLUSH PRIVILEGES;

SHOW GRANTS FOR 'appuser'@'localhost';
```

## ⚙️ F. Backend Setup (Port 3000)
```bash
cd backend
npm cache clean --force
npm install
nohup npm start &
sudo lsof -i :3000 --> Verify PID of running process
```
Check if backend is running:

```bash
curl http://localhost:3000/api/students
```
Or Ec2: Public IP with port : 3000
http://44.242.192.67:3000/api/students

## 💻 G. Frontend Setup (Port 8080)
✅ 1. Update script.js
In the frontend directory, update:

```javascript
const API_URL = 'http://<your-ec2-public-ip>:3000/api/students';
```
✅ 2. Start a Simple Web Server
```bash
cd ../frontend
python3 -m http.server 8080
```
Open: http://<your-ec2-ip>:8080

## 🧪 H. Test the App End-to-End
- Access the app in the browser
- Add a new student → Verify entry
- Edit or delete a student
- Confirm MySQL is storing data correctly

## 📁 I. Directory Structure of the App
```
student-management-system/
├── backend/
│   ├── db.js
│   ├── package.json
│   ├── package-lock.json
│   └── server.js
├── database/
│   └── setup.sql
├── frontend/
│   ├── index.html
│   ├── script.js
│   └── style.css
└── setup.md
```
This structure is pre-built — students can just run and follow instructions.

## 🎯 Task for Today
✅ Launch a new EC2 instance on AWS
✅ SSH into the server
✅ Install all required packages
✅ Clone and deploy the Student Management System manually
✅ Run the backend and frontend apps
✅ Test the app from your browser using the public EC2 IP

## Bonus Task
✅ Buy a domain in godady
✅ Create hosted zone in RT53, Copy the NS record and update to godady - NS
✅ Create target Group, Create ALB , Create Record set and map ALB DNS to subdomain "day02.xyz.com"
✅ Access App using domain "http://day02.xyz.com" in browser.

## ✅ Outcome
By the end of Day 2, you will:

✅ Understand how to launch and access EC2 instances
✅ Be confident in setting up a server manually
✅ Deploy a real multi-part application to a cloud server
✅ Know how to expose ports and test end-to-end connectivity