# Day-11: Terraform Fundamentals

Welcome to Day-11 of the DevOps learning journey! Today we'll learn the fundamentals of Infrastructure as Code (IaC) using Terraform with proper enterprise-grade file organization.

## 🎯 Learning Objectives

By the end of this lesson, students will understand:
- What is Infrastructure as Code (IaC)
- Core Terraform concepts and terminology
- How to write, plan, and apply Terraform configurations
- Best practices for organizing Terraform code
- State management fundamentals
- Enterprise-grade file structure patterns

## 📁 File Structure (Enterprise Best Practices)

```
Day-11/

tf-code/
├── versions.tf           # Terraform version constraints and required providers
├── providers.tf          # Provider configurations (AWS, Random, etc.)
├── variables.tf          # Input variable definitions
├── terraform.tfvars      # Variable values (environment-specific)
├── locals.tf             # Local values and computed data
├── data.tf               # Data sources (existing resources)
├── security.tf           # Security groups, IAM roles, key pairs
├── compute.tf            # EC2 instances, launch templates, compute resources
├── storage.tf            # S3 buckets, EBS volumes, storage resources
├── monitoring.tf         # CloudWatch logs, alarms, dashboards
├── outputs.tf            # Output values
├── user_data.sh          # EC2 bootstrap script
└── README.md            # This file
```

## 🏗️ File Organization Benefits

This enterprise-grade structure provides:

### **Separation of Concerns**
- Each file has a specific purpose and resource type
- Easy to locate and modify specific components
- Reduces complexity and improves maintainability

### **Team Collaboration**
- Multiple developers can work on different files simultaneously
- Clear ownership and responsibility for different infrastructure components
- Easier code reviews and conflict resolution

### **Scalability**
- Easy to add new resource types in appropriate files
- Modular structure supports growth and complexity
- Can be easily converted to Terraform modules

### **Best Practices**
- Follows industry standards used by enterprise teams
- Prepares students for real-world DevOps environments
- Demonstrates professional Terraform project structure

## 🛠️ Prerequisites

Before starting, ensure you have:

1. **AWS Account** with appropriate permissions
2. **Terraform installed** (version >= 1.0)
3. **AWS CLI configured** with your credentials
4. **SSH key pair** (optional, for EC2 access)

### Installation Commands

```bash
# Install Terraform (Linux/Mac)
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# Verify installation
terraform --version

# Configure AWS CLI
aws configure
```

## 🚀 Getting Started

### Step 1: Clone and Navigate
```bash
git clone https://github.com/toktechteam/15-Days-DevOps-Job-Journey.git
cd 15-Days-DevOps-Job-Journey/Day-11/tf-code
```

### Step 2: Understand the File Structure
Take time to examine each file and understand its purpose:

```bash
# View the file organization
ls -la

# Examine each file's purpose
cat versions.tf     # Version constraints
cat providers.tf    # Provider configurations
cat variables.tf    # Variable definitions
cat data.tf         # Data sources
# ... and so on
```

### Step 3: Customize Variables
Edit `terraform.tfvars` file:
```hcl
aws_region = "us-east-1"           # Your preferred region
environment = "dev"                # Environment name
owner_email = "your@email.com"     # Your email
instance_type = "t3.micro"         # Instance size
allowed_ssh_cidr = "YOUR_IP/32"    # Your IP for SSH
```

### Step 4: Initialize Terraform
```bash
terraform init
```
This command:
- Downloads required provider plugins
- Initializes the working directory
- Prepares for terraform operations

### Step 5: Validate the Configuration
```bash
terraform validate
```
This checks for syntax errors and validates the configuration.

### Step 6: Format the Code
```bash
terraform fmt
```
This formats your code according to Terraform style guidelines.

### Step 7: Plan the Deployment
```bash
terraform plan
```
This command:
- Shows what resources will be created
- Validates your configuration
- Estimates costs (if configured)

### Step 8: Apply the Configuration
```bash
terraform apply
```
This command:
- Creates the planned resources
- Updates the state file
- Shows outputs when complete

### Step 9: Verify Deployment
After successful apply, you'll see comprehensive outputs including:
```
instance_public_ip = "54.123.45.67"
application_url = "http://54.123.45.67"
ssh_connection_command = "ssh -i demo-keypair.pem ec2-user@54.123.45.67"
s3_bucket_name = "dev-devops-demo-bucket-a1b2c3d4"
```

## 📚 Key Terraform Concepts Demonstrated

### 1. **File Organization Patterns**
- **versions.tf**: Version constraints and backend configuration
- **providers.tf**: Provider configurations and default tags
- **variables.tf**: Input variable definitions with validation
- **locals.tf**: Computed values and naming conventions
- **data.tf**: External data sources and existing resources

### 2. **Resource Organization**
- **security.tf**: All security-related resources
- **compute.tf**: EC2 instances and compute resources
- **storage.tf**: S3 buckets and storage resources
- **monitoring.tf**: CloudWatch and observability resources
- **outputs.tf**: All output values with descriptions

### 3. **Advanced Features**
- Variable validation and type constraints
- Conditional resource creation
- Dynamic resource configuration
- Comprehensive tagging strategy
- Lifecycle management rules

## 🏗️ Resources Created

This configuration creates:

### **Compute Resources**
- EC2 Instance with Amazon Linux 2
- Launch Template (production only)
- CloudWatch Alarms for monitoring

### **Security Resources**
- Security Group with proper rules
- Key Pair for SSH access
- IAM Roles (production only)

### **Storage Resources**
- S3 Bucket with versioning and encryption
- Demo files and configuration objects
- Additional EBS volumes (production only)

### **Monitoring Resources**
- CloudWatch Log Groups
- Custom Metrics and Alarms
- Dashboard (if monitoring enabled)
- SNS Topics for alerts (production only)

## 🔧 Common Commands

```bash
# Initialize working directory
terraform init

# Format code according to standards
terraform fmt

# Validate configuration
terraform validate

# Plan changes
terraform plan

# Apply changes
terraform apply

# Show current state
terraform show

# List resources
terraform state list

# Get specific output
terraform output instance_public_ip

# Get all outputs in JSON
terraform output -json

# Destroy all resources
terraform destroy
```

## 🎓 Student Exercises

### Exercise 1: File Structure Understanding
1. Examine each `.tf` file and identify its purpose
2. Find where variables are defined vs. where they're used
3. Trace how data flows between files

### Exercise 2: Variable Modifications
1. Add a new variable for instance name prefix
2. Use the variable in the `locals.tf` file
3. Apply changes and observe the naming

### Exercise 3: Resource Additions
1. Add a new S3 bucket in `storage.tf`
2. Create outputs for the new bucket in `outputs.tf`
3. Test the changes with plan and apply

### Exercise 4: Security Enhancements
1. Add a new security group rule in `security.tf`
2. Create a custom IAM policy
3. Test the security configurations

### Exercise 5: Environment Variations
1. Create separate `.tfvars` files for dev, staging, prod
2. Deploy the same code with different configurations
3. Compare the resources created

## 🔍 File-by-File Learning Guide

### **versions.tf** - Version Management
```hcl
# Learn about:
- Terraform version constraints
- Provider version management
- Backend configuration for team collaboration
```

### **providers.tf** - Provider Configuration
```hcl
# Learn about:
- AWS provider configuration
- Default tags strategy
- Multi-provider setups
```

### **variables.tf** - Input Management
```hcl
# Learn about:
- Variable types and validation
- Default values and descriptions
- Complex variable structures
```

### **locals.tf** - Computed Values
```hcl
# Learn about:
- Local value computation
- Naming conventions
- Conditional logic
- Resource name standardization
```

### **data.tf** - External Data
```hcl
# Learn about:
- Fetching existing AWS resources
- Data source filtering
- Using external information
```

### **security.tf** - Security Best Practices
```hcl
# Learn about:
- Security group organization
- IAM roles and policies
- Access control patterns
- Security rule management
```

### **compute.tf** - Compute Resources
```hcl
# Learn about:
- EC2 instance configuration
- Launch templates
- Compute-related resources
- Instance lifecycle management
```

### **storage.tf** - Storage Solutions
```hcl
# Learn about:
- S3 bucket configuration
- EBS volume management
- Storage encryption
- Lifecycle policies
```

### **monitoring.tf** - Observability
```hcl
# Learn about:
- CloudWatch configuration
- Custom metrics and alarms
- Dashboard creation
- Logging strategies
```

### **outputs.tf** - Information Export
```hcl
# Learn about:
- Output organization
- Sensitive data handling
- Information for other systems
- User-friendly output formatting
```

## 🏆 Enterprise Best Practices Demonstrated

1. **File Organization** - Clear separation of concerns
2. **Naming Conventions** - Consistent resource naming
3. **Variable Management** - Proper input validation
4. **Security** - Least privilege and encryption
5. **Monitoring** - Comprehensive observability
6. **Documentation** - Clear comments and descriptions
7. **State Management** - Remote state considerations
8. **Team Collaboration** - Structured for multiple developers

## 🔄 Cleanup

To avoid AWS charges, destroy resources when done:
```bash
terraform destroy
```

Type `yes` when prompted. This will remove all created resources.

## 📖 Additional Resources

- [Terraform Documentation](https://developer.hashicorp.com/terraform/docs)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [Terraform Style Guide](https://developer.hashicorp.com/terraform/language/style)

## 🎯 Next Steps

Tomorrow (Day-12), we'll use this organized structure to:
- Create more complex EC2 infrastructure
- Deploy our actual applications
- Implement advanced Terraform patterns
- Build production-ready environments

---

**Happy Learning! 🚀**

*Remember: Proper file organization is crucial for maintainable, scalable, and collaborative Infrastructure as Code!*