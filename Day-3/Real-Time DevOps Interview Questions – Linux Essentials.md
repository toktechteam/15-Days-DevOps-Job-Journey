
# ✅ Real-Time DevOps Interview Questions – Linux Essentials (Day 3)

---

### 1. **You created a user using `useradd`, but the user can't log in. What could be wrong?**

**Answer:**  
By default, `useradd` may not create a home directory or assign a shell. You should use:
```bash
sudo useradd -m -s /bin/bash devuser
```
- `-m`: creates home directory
- `-s /bin/bash`: sets shell  
  Also check `/etc/passwd` to confirm the shell is set correctly.

---

### 2. **A script throws “Permission denied” even after you gave 755 permission. What could be the cause?**

**Answer:**  
Likely issues:
- The script has `\r\n` line endings from Windows — fix with:
```bash
dos2unix script.sh
```
- You're not in the correct directory:  
  Use `./script.sh` instead of `script.sh`

---

### 3. **How can you find all files modified in the last 1 hour in `/var/log`?**

**Answer:**
```bash
find /var/log -type f -mmin -60
```
This finds all files modified within the last 60 minutes.

---

### 4. **You installed a service like NGINX but it doesn't start. How will you troubleshoot?**

**Answer:**
1. Check the service status:
```bash
sudo systemctl status nginx
```
2. Look at the logs:
```bash
journalctl -xe
```
3. Test the config:
```bash
nginx -t
```

---

### 5. **What is the difference between `chmod 755` and `chmod 644`?**

**Answer:**
- `755` → Owner: rwx | Group: r-x | Others: r-x  
  Used for **executables/scripts**
- `644` → Owner: rw | Group: r | Others: r  
  Used for **normal config or text files**

---

### 6. **How can you list only directories inside `/etc` recursively that were modified today?**

**Answer:**
```bash
find /etc -type d -daystart -mtime 0
```

---

### 7. **You added a new user but that user is getting “Permission denied” when trying to install packages. What do you check?**

**Answer:**
Make sure the user is in the `sudo` group:
```bash
groups username
```
If not, add them:
```bash
sudo usermod -aG sudo username
```

---

### 8. **How would you monitor CPU usage and auto-restart a process if it exceeds 90% CPU?**

**Answer:**  
Write a script using `top` or `ps`:
```bash
#!/bin/bash
CPU=$(ps -eo pid,%cpu,cmd --sort=-%cpu | awk 'NR==2 {print $2}')
if (( $(echo "$CPU > 90.0" | bc -l) )); then
  systemctl restart myapp.service
fi
```

---

### 9. **How do you check if a specific port (e.g., 80) is being used and by which process?**

**Answer:**
```bash
sudo lsof -i :80
```
or
```bash
sudo netstat -tulnp | grep :80
```

---

### 10. **You’re inside a production server and accidentally ran `rm -rf /tmp/*`. How would you recover or what would you do next?**

**Answer:**
- `/tmp` is often used by running services (e.g., MySQL socket)
- Immediately check running apps
- Restart critical services (e.g., `sudo systemctl restart mysql`)
- Use logs to investigate what failed and reinitialize required temp files

---
