
# 🌍 Day 10: Terraform Basics – Infrastructure as Code (IaC)

Welcome to Day 10 of your DevOps Bootcamp!  
Today you’ll learn how to **automate cloud infrastructure provisioning** using **Terraform** — one of the most essential tools in modern DevOps.

---

## 🧠 A. What is Terraform?

Terraform is an **open-source tool by HashiCorp** that lets you define, manage, and provision cloud infrastructure using code.

You write this code in **HCL (HashiCorp Configuration Language)** and apply it using a few simple commands — automating the creation of:
- EC2 Instances
- S3 Buckets
- IAM Roles
- VPCs
- Databases
  ...and much more.

---

## 🔥 B. Why DevOps Engineers Love Terraform

- ✅ Automates Infrastructure (No more manual clicking)
- ✅ Version-controlled (code is stored in Git)
- ✅ Platform Agnostic (Supports AWS, Azure, GCP, Kubernetes, etc.)
- ✅ Scalable, auditable, and reproducible

---

## 🛠️ C. Core Terraform Commands (Your Daily Toolkit)

| Command             | Purpose                                      |
|---------------------|----------------------------------------------|
| `terraform init`    | Initialize your working directory            |
| `terraform plan`    | Show what Terraform will do (dry-run)        |
| `terraform apply`   | Apply the changes and provision resources    |
| `terraform destroy` | Tear down and remove infrastructure          |

---

## 📦 D. Hands-On: Create an EC2 Instance with Terraform

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
```

---

## ✅ Terraform Installation – Mac, Windows, Linux (Bonus)

Here’s how your students can install Terraform based on their OS.

---

### 💻 For **MacOS** (via Homebrew)
```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
terraform -v
```

> 💡 You can also upgrade anytime with:
```bash
brew upgrade hashicorp/tap/terraform
```

---

### 🪟 For **Windows**
1. Download Terraform from: https://www.terraform.io/downloads.html
2. Extract the zip and move `terraform.exe` to a folder like `C:\Terraform`
3. Add that folder to your **System PATH**:
    - Search “Environment Variables” → Edit the PATH variable → Add new
    - Then open new terminal and run:
```powershell
terraform -v
```

---

### 🐧 For **Linux (Debian/Ubuntu)**
```bash
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform -y
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

### ✅ 2. Project Structure

```bash
mkdir terraform-ec2 && cd terraform-ec2
touch main.tf
```

---

### ✅ 3. Write Your First Terraform Code (main.tf)

```hcl
provider "aws" {
  region     = "us-west-2"

  # Avoid hardcoding keys in production
  access_key = "xxxxx"
  secret_key = "xxxxx"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_instance" "devops" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  tags = {
    Name = "DevOpsEC2"
  }
}
```

> 🛡️ **Security Note:** Don’t hardcode AWS keys. Use **environment variables**, **AWS profiles**, or **IAM roles**.

---

### ✅ 4. Run Terraform Commands

```bash
terraform init       # Initialize project
terraform plan       # Preview what will be created
terraform apply      # Create EC2 instance
```

Check AWS Console → EC2 → You should see your instance.

---

## 🔍 Bonus: Where Terraform Stores State?

Terraform stores the state of your infrastructure in a file called `terraform.tfstate`.  
This file is critical — it tracks all the real-world infrastructure and maps it to your code.

> 💡 Use remote backends (like S3 + DynamoDB) for team environments.

---

## 🧠 Understanding Terraform State File (`terraform.tfstate`)

---

### 📁 What is `terraform.tfstate`?

Terraform keeps track of **what infrastructure it manages** in a state file.  
It’s a **JSON file** that maps the real-world resources (in AWS, Azure, etc.) with your Terraform configuration.

---

### ✅ Why is State File Important?

- Tracks existing resources to avoid recreating them
- Ensures **idempotency** (Terraform won't duplicate resources)
- Used to **plan diffs** between current state vs desired config

---

### ⚠️ Common Problems Without State

- Terraform might re-create infrastructure accidentally
- No way to know what was provisioned or destroyed
- Collaboration becomes impossible (state lives only on one machine)

---

## 🧰 What is State Locking?

Terraform **locks** the state when performing an operation to prevent concurrent modification.  
This is managed automatically when using **remote backends** like **S3 + DynamoDB**.

---

## 💾 Default Local State Example

When you run Terraform for the first time:

```bash
terraform init
terraform apply
```

It creates a file:

```bash
terraform.tfstate
```

Located in your working directory. Sample snippet:

```json
{
  "version": 4,
  "resources": [
    {
      "type": "aws_instance",
      "name": "devops",
      "instances": [
        {
          "attributes": {
            "ami": "ami-0c02fb55956c7d316",
            "instance_type": "t2.micro"
          }
        }
      ]
    }
  ]
}
```

---

## ☁️ Moving to Remote State with AWS S3 + DynamoDB

> 📌 Recommended for teams and production

### ✅ Step 1: Create an S3 Bucket and DynamoDB Table

```bash
aws s3api create-bucket --bucket devops-terraform-state --region us-west-2

aws dynamodb create-table \
  --table-name terraform-lock-table-new \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-west-2
  
```

---

### ✅ Step 2: Update Your Terraform Code (`main.tf`)

```hcl
terraform {
  backend "s3" {
    bucket         = "devops-terraform-state"
    key            = "devops/ec2/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}

provider "aws" {
  region     = "us-east-1"
}
```

---

### ✅ Step 3: Initialize Backend

```bash
terraform init
```

> Terraform will ask if you want to copy the existing local state to S3 — choose **yes**.

---

### 🔐 What Happens Now?

- Your `terraform.tfstate` is stored securely in S3
- Terraform locks the file using the DynamoDB table
- You can collaborate with your team safely

---

## ⚠️ Common Pitfalls (Interview Tips)

| Issue                         | What to Do                                |
|------------------------------|--------------------------------------------|
| Hardcoded AWS secrets         | Use environment variables or IAM roles     |
| No `terraform init` run       | Run before plan/apply                      |
| Re-running without destroy    | May cause duplicates or errors             |
| State file lost               | You lose all tracking (keep backups!)      |

---

## 🎯 Task for Today

- ✅ Install Terraform on your EC2 or local machine
- ✅ Write a working `main.tf` that provisions an EC2 instance
- ✅ Apply and verify the instance in AWS Console

---

## ✅ Outcome

By end of Day 10, you will:
- ✅ Understand the fundamentals of Terraform and IaC
- ✅ Write and execute your first working Terraform script
- ✅ Be able to launch real AWS infrastructure from code

---

## ✅ Best Practices

- Never commit `.tfstate` to Git
- Use versioning and encryption on S3
- Enable server-side encryption (SSE-S3 or SSE-KMS)
- Use IAM policies to restrict access to the state bucket/table

---

## 🧪 Final Task

1. Create an S3 bucket and DynamoDB table
2. Configure your Terraform backend as shown
3. Run `terraform init` and verify the state appears in S3
4. Run `terraform plan` and `apply` to create resources
5. Confirm locking works by trying a second `apply` in parallel

---

## ✅ Outcome

- You understand what the state file is and why it matters
- You’ve set up remote state storage with locking
- Your infra is now collaboration-ready and production-grade!

## ⏭️ Up Next: Day 11 – Reusable Infrastructure with Variables, Outputs, and Multiple Resources!
