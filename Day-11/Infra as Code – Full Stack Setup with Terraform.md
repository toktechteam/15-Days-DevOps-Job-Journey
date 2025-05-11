# 🌍 Day 11: Infra as Code – Full Stack Setup with Terraform

Welcome to Day 11 of your DevOps Bootcamp!
Today we move from basic EC2 creation to a **full working stack** using **variables**, **security groups**, and **outputs** in Terraform.
Let's make infrastructure flexible, reusable, and dynamic!

---

# 🎯 What You Will Learn Today
- How to modularize Terraform code using variables and outputs
- How to create and manage AWS Security Groups via Terraform
- How to configure AWS CLI and use profiles securely
- How to deploy EC2 instances with dynamic outputs
- How to setup backend using S3 + DynamoDB for remote state management

---

## 🛠 Project Structure
```bash
terraform-project/
├── main.tf
├── variables.tf
├── outputs.tf
```

### ✅ Prerequisite: Launch EC2 Instance

| Setting              | Value                                                    |
|----------------------|----------------------------------------------------------|
| Name                 | devops-day10                                             |
| OS                   | Amazon Linux 2023 AMI 2023, ami-05572e392e80aee89        |
| Instance type        | t3.medium                                                |
| Key pair             | Create new, download `.pem` file                         |
| Security group       | Allow SSH (22), HTTP (80), Custom TCP (8080, 3000, 9000) |


### Connect to EC2:
```bash
chmod 400 your-key.pem
ssh -i your-key.pem ec2-user@<EC2-PUBLIC-IP>

copy main.tf file to your system and verify
```
---

### Linux AMI 2023

```bash
# Update packages and install prerequisites
sudo dnf update -y

# Create directory for the repository configuration
sudo mkdir -p /etc/yum.repos.d/

# Download and install HashiCorp's repository configuration
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo

# Install Terraform
sudo dnf install -y terraform

```

---
After installation, verify with:
```bash
terraform version
```

✅ Done! You’re now ready to write Terraform code!


## 📄 2. variables.tf (For Flexibility)
```hcl
variable "region" {}
variable "profile" {}
```

---

## 📄 3. outputs.tf (Get Instance IP Automatically)
```hcl
output "instance_ip" {
  value = aws_instance.web.public_ip
}
```

---

# 🛠 AWS CLI Setup (Mandatory)

Before running Terraform commands, ensure AWS CLI is installed and configured:

### Install AWS CLI:
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

### Configure Profile:
```bash
aws configure --profile devprofile
```
Provide:
- AWS Access Key
- AWS Secret Key
- Region

---

# ☁️ Terraform Backend Setup (Optional - Best Practice)

Use S3 + DynamoDB backend for storing terraform.tfstate securely.

Add this block at the top of `main.tf`:
```hcl
terraform {
  backend "s3" {
    bucket         = "your-s3-bucket-name"
    key            = "terraform-project/terraform.tfstate"
    region         = var.region
    dynamodb_table = "your-dynamodb-lock-table"
    encrypt        = true
  }
}
```
> 💡 Make sure the S3 bucket and DynamoDB table already exist!

---

# 🧪 Lab Task for You

✅ Create project folder with main.tf, variables.tf, outputs.tf  
✅ Install AWS CLI and configure a profile (recommended: "devprofile")  
✅ Deploy EC2 instance with a security group allowing SSH (22) and HTTP (80)  
✅ Output Public IP using Terraform outputs  
✅ Connect to the instance using SSH  
✅ (Bonus) Setup backend in S3 and DynamoDB for state management

### Sample Commands
```bash
terraform init
terraform plan -var="region=us-west-2" -var="profile=default" -var="key_name=deployer-key"
terraform apply -var="region=us-west-2" -var="profile=default" -var="key_name=deployer-key"
terraform destroy -var="region=us-west-2" -var="profile=default" -var="key_name=deployer-key"

```

---

# ✅ Outcome from Day 11

By completing today's lab, you will:
- Understand real-world Terraform project structure
- Use AWS CLI with profiles securely
- Create EC2 instance + Security Group modularly
- Output and retrieve Public IP dynamically
- Setup S3 + DynamoDB remote backend (Production-Grade)
- Be one step closer to building fully automated cloud infrastructure

---

# 📢 Next Up: Day 12 – Monitoring Instance with Prometheus + Grafana!

Get ready to dive into real-time monitoring like a pro 🚀

---
