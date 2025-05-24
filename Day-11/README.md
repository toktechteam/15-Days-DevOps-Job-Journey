# Day-11: Terraform Basics

Learn Infrastructure as Code with Terraform basics.

## 📁 Files

```
Day-11/
├── main.tf           # Main configuration (all resources)
├── variables.tf      # Variable definitions
├── outputs.tf        # Output values
├── dev.tfvars       # Development environment
├── staging.tfvars   # Staging environment  
├── prod.tfvars      # Production environment
├── user_data.sh     # EC2 setup script
└── README.md        # This guide
```

## 🛠️ Prerequisites

1. AWS Account
2. Terraform installed
3. AWS CLI configured

## 🚀 Complete Terraform Command Series

Follow these commands step-by-step to deploy your infrastructure:

### **Step 1: Prepare Environment**
```bash
# Navigate to Day-11 directory
cd Day-11/

# Check Terraform version
terraform version

# Check AWS credentials
aws sts get-caller-identity
```

### **Step 2: Initialize Terraform**
```bash
# Initialize Terraform (downloads providers)
terraform init
```

### **Step 3: Format and Validate Code**
```bash
# Format code (makes it look nice)
terraform fmt

# Validate configuration (check for errors)
terraform validate
```

### **Step 4: Plan Deployment**
```bash
# Plan for development environment
terraform plan -var-file="dev.tfvars"

# Optional: Save plan to file
terraform plan -var-file="dev.tfvars" -out="dev.tfplan"
```

### **Step 5: Deploy Infrastructure**
```bash
# Apply for development environment
terraform apply -var-file="dev.tfvars"

# Or apply saved plan
terraform apply "dev.tfplan"

# Auto-approve (skip confirmation)
terraform apply -var-file="dev.tfvars" -auto-approve
```

### **Step 6: Verify Deployment**
```bash
# Show all outputs
terraform output

# Get specific output
terraform output instance_public_ip

# List all resources
terraform state list

# Show detailed state
terraform show
```

### **Step 7: Test Application**
```bash
# Get public IP
PUBLIC_IP=$(terraform output -raw instance_public_ip)

# Test the application
curl http://$PUBLIC_IP

# Test via browser (copy this URL)
echo "http://$PUBLIC_IP"
```

### **Step 8: Make Changes (Optional)**
```bash
# If you modify any .tf files, repeat:
terraform fmt
terraform validate
terraform plan -var-file="dev.tfvars"
terraform apply -var-file="dev.tfvars"
```

### **Step 9: Deploy to Other Environments**
```bash
# For staging
terraform plan -var-file="staging.tfvars"
terraform apply -var-file="staging.tfvars"

# For production
terraform plan -var-file="prod.tfvars"
terraform apply -var-file="prod.tfvars"
```

### **Step 10: Clean Up**
```bash
# Destroy development environment
terraform destroy -var-file="dev.tfvars"

# Auto-approve destruction
terraform destroy -var-file="dev.tfvars" -auto-approve

# Verify everything is destroyed
terraform state list
```

## ⚡ Quick One-Liner for Students

```bash
# Complete workflow in one command block
terraform init && \
terraform fmt && \
terraform validate && \
terraform plan -var-file="dev.tfvars" && \
terraform apply -var-file="dev.tfvars" -auto-approve && \
terraform output
```

## 📚 What You'll Learn

- **main.tf**: All resources in one file
- **variables.tf**: How to define variables
- **outputs.tf**: How to display results
- **Environment files**: Different configurations

## 🏗️ Resources Created

1. **EC2 Instance** - Web server with demo app
2. **Security Group** - Network rules
3. **Key Pair** - SSH access
4. **S3 Bucket** - File storage

## 🔧 Essential Terraform Commands

```bash
terraform init          # Initialize
terraform fmt           # Format code
terraform validate      # Check for errors
terraform plan          # Preview changes
terraform apply         # Create resources
terraform output        # Show outputs
terraform state list    # List resources
terraform destroy       # Delete resources
```

## 🔍 Troubleshooting Commands

```bash
# Check Terraform logs
export TF_LOG=DEBUG
terraform apply -var-file="dev.tfvars"

# Refresh state
terraform refresh -var-file="dev.tfvars"

# Force unlock (if state is locked)
terraform force-unlock LOCK_ID

# Get help
terraform -help
terraform apply -help
```

## 📊 Useful Learning Commands

```bash
# Show resource dependencies
terraform graph

# Show providers
terraform providers

# Show current workspace
terraform workspace show
```

## 🎯 Student Exercises

1. **Basic Practice:**
    - Change instance type in dev.tfvars from t3.micro to t3.small
    - Run terraform plan and apply to see the changes

2. **Variable Practice:**
    - Add a new variable for owner name in variables.tf
    - Use it in resource tags in main.tf

3. **Environment Practice:**
    - Create test.tfvars for testing environment
    - Deploy to test environment

4. **Customization Practice:**
    - Modify user_data.sh to install different software
    - Apply changes and test

## 🚨 Common Issues & Solutions

**Error: "No valid credential sources"**
```bash
aws configure
```

**Error: "InvalidKeyPair.NotFound"**
- Replace the public key in main.tf with your own SSH public key

**Error: "UnauthorizedOperation"**
- Check your AWS IAM permissions for EC2 and S3

**Error: "BucketAlreadyExists"**
- S3 bucket names must be globally unique, try again (random suffix will change)

## 💡 Pro Tips for Students

1. **Always validate first:** Run `terraform validate` before `terraform plan`
2. **Use different environments:** Practice with dev.tfvars first, then try staging
3. **Save your plans:** Use `-out` flag to save plans for review
4. **Check outputs:** Always run `terraform output` after successful apply
5. **Clean up:** Don't forget to run `terraform destroy` to avoid charges

## 🎓 Learning Flow

1. **Start Here:** Run the complete command series above
2. **Understand:** Read through main.tf to understand each resource
3. **Experiment:** Try the student exercises
4. **Practice:** Deploy to different environments
5. **Master:** Create your own modifications

---

**Remember: Practice makes perfect!** 🚀

Happy Learning! 🎓