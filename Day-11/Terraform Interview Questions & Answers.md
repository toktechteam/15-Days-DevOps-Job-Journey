
# 🌍 Day 10 – Terraform Interview Questions & Answers (Job-Focused)

---

### 1. **What is Terraform and how is it different from CloudFormation?**

**Answer:**  
Terraform is an open-source, cloud-agnostic IaC tool using HCL syntax.  
CloudFormation is AWS-specific and uses JSON/YAML.

| Feature        | Terraform          | CloudFormation         |
|----------------|--------------------|------------------------|
| Language       | HCL                | JSON/YAML              |
| Multi-Cloud    | ✅ Yes              | ❌ AWS Only            |
| Modular        | ✅ Highly Modular   | 🚫 Limited             |
| Community      | ✅ Huge Ecosystem   | 🟡 Smaller             |

---

### 2. **What is a Terraform state file and why is it important?**

**Answer:**  
`terraform.tfstate` tracks the real infrastructure Terraform manages.  
It maps what’s been provisioned to what exists in code.  
Without it, Terraform cannot determine what needs to change.

---

### 3. **How do you secure a Terraform state file?**

**Answer:**
- Store it remotely in **S3** with **encryption**
- Enable **versioning** to roll back changes
- Use **DynamoDB** table for **state locking**
- Restrict access via **IAM policies**

---

### 4. **How can you share Terraform state with your team?**

**Answer:**  
Use **remote backend** like:
- S3 + DynamoDB (AWS)
- Terraform Cloud or Enterprise
  This allows centralized, locked state management and collaboration.

---

### 5. **What are Terraform modules and why are they useful?**

**Answer:**  
Modules are reusable pieces of Terraform code.
They help:
- DRY (Don’t Repeat Yourself)
- Standardize infra (like common VPC, EC2 patterns)
- Enable team collaboration

Example:
```hcl
module "vpc" {
  source = "./modules/vpc"
  cidr_block = "10.0.0.0/16"
}
```

---

### 6. **What are Terraform providers and how do they work?**

**Answer:**  
A provider is a plugin that interacts with an API (AWS, Azure, GitHub, etc.)
It defines the **resources** you can use (e.g., aws_instance).

```hcl
provider "aws" {
  region = "us-east-1"
}
```

---

### 7. **What happens when you run `terraform plan` vs `terraform apply`?**

**Answer:**
- `terraform plan`: Shows proposed changes (dry-run)
- `terraform apply`: Actually provisions or changes infrastructure

---

### 8. **How do you avoid hardcoding credentials in Terraform code?**

**Answer:**
- Use **environment variables** (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`)
- Use **AWS CLI profile**
- Use **IAM roles** for EC2
- Store secrets in **Vault** or **SSM Parameter Store**

---

### 9. **What’s the difference between `terraform destroy` and `terraform taint`?**

**Answer:**
- `terraform destroy`: Removes **all resources** managed by the config
- `terraform taint`: Forces re-creation of **a single resource**

---

### 10. **How can you create infrastructure for multiple environments (dev/stage/prod)?**

**Answer:**
Use:
- **Workspaces** (`terraform workspace new dev`)
- **Variable files** like `dev.tfvars`, `prod.tfvars`
- Directory-based structure: `dev/`, `prod/`, each with its own `main.tf`

---
