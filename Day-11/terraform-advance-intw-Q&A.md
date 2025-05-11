### Q. Why should we use variables and outputs in Terraform?
**Answer:**
- Variables = flexibility + reusability (no hardcoding)
- Outputs = fetch dynamic resource info after deployment

### Q. Why do we configure AWS CLI and profiles?
**Answer:**
- Secure authentication
- Separate environments (dev/stage/prod)

### Q. Why move state to S3 and lock with DynamoDB?
**Answer:**
- Collaboration-ready infra
- Protect state from corruption
- Auto-locking to avoid concurrent issues

### Q. Why should you attach a Key Pair to an EC2 instance?
**Answer:**
- For secure SSH access to your EC2 instance.
- Without a Key Pair, you cannot connect via SSH.

### Q. What is a "data" block in Terraform and why is it used?
**Answer:**
- A "data" block is used to **fetch read-only information** about existing resources outside Terraform control (e.g., default VPC, existing AMI).
- Example: `data "aws_vpc" "default" { default = true }`

### Q. Why do we use "backend" configuration in Terraform?
**Answer:**
- Backend stores the Terraform state file remotely (e.g., S3) to allow **team collaboration** and **safe state management**.
- It enables features like **state locking**, **versioning**, and **remote operations**.

### Q. How does `variables.tf` and `.tfvars` file work together in Terraform?
**Answer:**
- `variables.tf` defines the **input variables**.
- `.tfvars` file provides the **values** for those variables separately.
- This keeps the code clean and supports multiple environments easily.

### Q. What happens if you don't use remote state in Terraform projects?
**Answer:**
- State files remain local ➔ high risk of corruption, conflicts, and data loss.
- Team cannot collaborate safely ➔ manual coordination needed ➔ more errors.

### Q. Explain the flow of "init", "plan", and "apply" in Terraform.
**Answer:**
- `terraform init` ➔ Prepares working directory, downloads providers and modules.
- `terraform plan` ➔ Shows the changes Terraform will make.
- `terraform apply` ➔ Executes the planned actions and provisions resources.