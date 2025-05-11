
# 🐧 Day 3: Linux Essentials for DevOps

Welcome to Day 3 of your DevOps Bootcamp.
Today, we go back to basics — like learning A-B-C. Step by step, you'll get comfortable with Linux commands, files, users, permissions, and automation.

---

## 📘 A. Why Every DevOps Engineer Must Know Linux

- 🌍 90% of cloud servers run Linux (AWS, Azure, GCP)
- 🛠️ Most DevOps tools are built for or run better on Linux
- 💻 Shell scripting + command-line = superpower
- 🔐 Better security, open-source, lightweight OS

---

## 📁 B. Your First Linux Environment

### ✅ Option 1: Install Ubuntu Desktop (for laptops/VM)
Get from [https://ubuntu.com/download](https://ubuntu.com/download)

### ✅ Option 2: Use WSL on Windows
```bash
wsl --install
```

Select Ubuntu from the available options.

---

## 💡 C. Linux Command Line – Start Here

# ✅ Click “Launch Instance”
| Setting              | Value                                                           |
|----------------------|-----------------------------------------------------------------|
| Name                 | devops-day03                                                    |
| OS                   | Ubuntu Server 22.04 LTS, SSD Volume Type, ami-0f9de6e2d2f067fca |
| Instance type        | t2.micro                                                        |
| Key pair             | Create new, download `.pem` file                                |
| Security group       | Allow SSH (22), HTTP (80), Custom Port (8080, 3000)             |

##  Launch and Connect via SSH

```bash
chmod 400 your-key.pem
ssh -i your-key.pem ubuntu@<your-ec2-public-ip>
```

---
| Command     | Description                          |
|-------------|--------------------------------------|
| `ls`        | List files and directories           |
| `cd`        | Change directory                     |
| `pwd`       | Print current working directory      |
| `mkdir`     | Create a directory                   |
| `touch`     | Create an empty file                 |
| `clear`     | Clear terminal screen                |
```
**✅ Tip:** Create multiple folders at once:
```bash
mkdir project/{frontend,backend,database}
```

---

## 📝 D. File and Directory Operations

```bash
cp source.txt backup.txt       # Copy
mv file.txt folder/            # Move or rename
rm file.txt                    # Delete file
rm -r folder/                  # Delete folder
cat file.txt                   # Show file content
nano file.txt                  # Edit file
```

---

## 🔐 E. Permissions and Ownership (This is Very Important!)

### 🔍 View Permissions
```bash
ls -l
```

You’ll see output like:
```
-rwxr-xr--  1 user group 1024 Apr 20 file.sh
```

### 🔐 Permission Breakdown: 4-2-1 Rule

Linux uses numbers to set permissions:

| Symbol | Value | Meaning  |
|--------|-------|----------|
| `r`    | 4     | Read     |
| `w`    | 2     | Write    |
| `x`    | 1     | Execute  |

- `7` = `rwx` = Full access
- `5` = `r-x` = Read + Execute
- `4` = `r--` = Read only

Example:
```bash
chmod 755 script.sh
```

- **User**: 7 → `rwx`
- **Group**: 5 → `r-x`
- **Others**: 5 → `r-x`

This means the file is fully accessible to the owner, and readable/executable by others.

---

## 👥 F. User Management and Sudo Explained

### ✅ Add a New User
```bash
sudo useradd devuser
sudo passwd devuser
```

### 🔍 How to Verify New Users
Check the last lines of this file:
```bash
cat /etc/passwd
```

Every user on your system is listed there. The last one should be the one you added.

### ❌ Delete a User
```bash
sudo userdel -r devuser
```

### 🔑 What is `sudo`?

`sudo` means “SuperUser DO”. It allows a **regular user** to execute **admin-level (root) commands** securely.

### 🧑‍💻 How to Become Superuser
You can switch to root with:
```bash
sudo su
```

Or, if you're already the admin user and just want to run one command with elevated privileges, use:
```bash
sudo <your-command>
```

### 👮‍♂️ Give Sudo Access to User
```bash
sudo usermod -aG sudo devuser
```

Then log out and log back in for it to take effect.

---

## 🔎 G. Advance Linux Comamnd 

### AWK - Text Processing
AWK is great for working with columnar data like CSV files or command outputs.

```bash
# Print specific columns from a file
# Syntax: awk '{print $column_number}' filename
# This prints the 1st column from /etc/passwd

$ awk -F: '{print $1}' /etc/passwd
```

This command:
1. Uses -F: to set the field separator to colon (:)
2. {print $1} tells awk to print only the first column
3. Result: A list of all usernames on the system`

### SED - Stream Editor
SED is useful for search and replace operations in text files.

```bash
# Replace text in a file
# Syntax: sed 's/old_text/new_text/g' filename
# This replaces "hello" with "hi" in a file
sed 's/hello/hi/g' example.txt
```
This command:

1. s/ indicates substitution
2. Replace "hello" with "hi"
3. /g means replace globally (all occurrences in each line)
4. The result is printed to standard output (original file remains unchanged)


### FIND - File Search
FIND helps locate files and directories based on various criteria.

```bash
# Find files by name
# Syntax: find starting_directory -name "pattern"
# This finds all .txt files in the current directory and subdirectories

find . -name "*.txt"
find . -name "*.sh"          # Find all shell scripts in current dir
find /var -type f -size +10M # Files > 10MB in /var
```
This command:

1. [.] dot tells find to start from the current directory
2. -name "*.txt" looks for files that end with .txt
3. Results in a list of paths to all text files in the current directory and subdirectories

### GREP - Pattern Search
GREP searches for patterns in files or command output.

```bash
# Search for text in files
# Syntax: grep "pattern" filename
# This finds lines containing "error" in a log file
grep "error" application.log
```
This command:

1. Searches for the word "error" in application.log
2. Displays all lines containing the word "error"
3. Is case-sensitive by default (use -i for case-insensitive search)



---

## 📂 H. Filesystem Structure

| Directory   | Purpose                            |
|-------------|-------------------------------------|
| `/`         | Root directory                      |
| `/home`     | User directories                    |
| `/etc`      | Configuration files                 |
| `/var/log`  | System/application logs             |
| `/usr/bin`  | Executable binaries                 |

---

## 📊 I. Monitoring System Performance

### ✅ Disk Space
```bash
df -h
```

### ✅ Memory
```bash
free -h
```

### ✅ CPU Info
```bash
lscpu
```

### ✅ Running Processes
```bash
ps aux | less
```

### ✅ Real-Time Monitoring
```bash
top
```

---

## 🧪 J. Practical Task – Your First Script

### 1. Create and Run Script
```bash
echo "echo Hello DevOps!" > hello.sh
chmod +x hello.sh
./hello.sh
```

### 2. Install NGINX
```bash
sudo apt update && sudo apt install nginx -y
```

### 3. Start and Check NGINX
```bash
sudo systemctl start nginx
sudo systemctl status nginx
```

### 4. View in Browser
Go to `http://localhost` → See NGINX default page.

---

## 🧼 K. Bonus Tips

- `history` – View your last used commands
- `man ls` – View manual for any command
- `Ctrl + C` – Cancel command
- `Ctrl + L` – Clear screen
- `tab` – Auto-complete

---

## ✅ Outcome Checklist

By end of Day 3, you can:
- ✅ Navigate Linux using CLI
- ✅ Manage files, directories, and permissions
- ✅ Understand 755, chmod and Linux permission system (4-2-1 logic)
- ✅ Add, delete, verify users using `/etc/passwd`
- ✅ Use and assign `sudo` access safely
- ✅ Install & verify software (like nginx)
- ✅ Monitor CPU, memory, disk & processes
- ✅ Write and run basic shell scripts

---

## ⏭️ Next Up: Docker – Let's build and run containers!
