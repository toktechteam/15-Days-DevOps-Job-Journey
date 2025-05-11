
# ☁️ Day 2 – AWS EC2 Interview Questions & Answers (Pro Edition)

---

### 1. **What is a Security Group in EC2, and how does it work?**

**Answer:**  
A Security Group acts as a **virtual firewall**. It controls inbound and outbound traffic **at the instance level**.
- Inbound rules control what traffic is allowed **to** the instance
- Outbound rules control what traffic is allowed **from** the instance  
  By default, Security Groups are **stateful**, so return traffic is automatically allowed.

---

### 2. **You can’t access your EC2 instance over SSH. What are possible causes?**

**Answer:**
- Port 22 is not allowed in the Security Group
- Wrong key pair or incorrect `.pem` file permissions
- Trying to connect with the wrong user (e.g., `ec2-user` instead of `ubuntu`)
- Instance has no public IP or Elastic IP attached

---

### 3. **What is an Elastic IP and when would you use it?**

**Answer:**  
An Elastic IP is a **static public IPv4 address** in AWS.  
You use it when:
- You want a consistent public IP across restarts
- Your EC2 instance needs to be accessible via a fixed endpoint (e.g., DNS, firewall)

---

### 4. **What is the difference between an AMI and an instance?**

**Answer:**
- **AMI (Amazon Machine Image)** is a snapshot/template used to launch instances
- **Instance** is a running virtual machine created from an AMI  
  You can customize an instance and then create a new AMI for future reuse or scaling.

---

### 5. **How do you back up data from an EC2 instance?**

**Answer:**  
You can:
1. Create an EBS snapshot
```bash
aws ec2 create-snapshot --volume-id vol-123456 --description "backup"
```
2. Or create an AMI from the instance which includes all EBS volumes.

---

### 6. **What is the difference between EBS and Instance Store volumes?**

**Answer:**
- **EBS (Elastic Block Store)**: Persistent storage, survives reboots and stops
- **Instance Store**: Ephemeral storage, tied to the lifetime of the instance

Use EBS for long-term data. Use Instance Store for temp/cache data.

---

### 7. **How can you increase the size of an EBS volume attached to an EC2 instance?**

**Answer:**
1. Modify volume size in AWS Console or CLI
2. Connect to the instance and resize the partition using:
```bash
sudo growpart /dev/xvda 1
sudo resize2fs /dev/xvda1
```

---

### 8. **How do you create a custom AMI from an EC2 instance?**

**Answer:**
1. Stop unnecessary services (optional)
2. From EC2 Console → Actions → Create Image
3. AWS creates a snapshot and registers it as a new AMI  
   You can now launch multiple instances using this image.

---

### 9. **What is the default behavior of EC2 if you stop and start an instance?**

**Answer:**
- The public IP changes unless you use Elastic IP
- Data in EBS remains (unless deleted on termination)
- Instance restarts with a new host but keeps the same volume

---

### 10. **What’s the best way to allow HTTP/HTTPS access only from a specific IP?**

**Answer:**  
Update the EC2 Security Group inbound rules:
- Allow port 80 (HTTP) or 443 (HTTPS)
- Set source to `your.ip.address/32` to restrict access

---
