
# 🐳 Day 4 – Real-Time Docker Interview Questions & Answers

---

### 1. **You built a Docker image, but the container fails to start. How will you troubleshoot?**

**Answer:**
1. Check logs:
```bash
docker logs <container_id>
```
2. Try running interactively:
```bash
docker run -it my-image bash
```
3. Check the Dockerfile’s `CMD` or `ENTRYPOINT` – maybe the command is incorrect or missing.

---

### 2. **How do you copy a configuration file into a running Docker container?**

**Answer:**
```bash
docker cp ./config.yaml <container_id>:/app/config.yaml
```

---

### 3. **What is the difference between a Docker image and a container?**

**Answer:**
- **Image**: A read-only blueprint (the recipe)
- **Container**: A running instance of the image (the cooked meal)

---

### 4. **How can two containers talk to each other using Docker networking?**

**Answer:**
1. Create a network:
```bash
docker network create mynet
```
2. Run both containers inside it:
```bash
docker run -d --name db --network mynet mysql
docker run -d --name app --network mynet my-app
```
Now `app` can reach `db` using hostname `db`.

---

### 5. **You ran `docker run` but forgot to name the container. How can you find it later?**

**Answer:**  
Use:
```bash
docker ps -a
```
It will show the container with a random name like `blissful_bardeen` which Docker auto-generates.

---

### 6. **Explain what `-v $(pwd)/html:/usr/share/nginx/html` does in a Docker run command.**

**Answer:**  
Mounts the current directory’s `html/` folder into the container path `/usr/share/nginx/html`. Any file changes in the host folder will reflect in the container instantly.

---

### 7. **How do you check which process is using port 80 inside a container?**

**Answer:**  
Run:
```bash
docker exec -it <container_id> bash
```
Then inside:
```bash
netstat -tulnp | grep :80
```

---

### 8. **You edited your Dockerfile but the changes aren't reflecting in the container. What might be wrong?**

**Answer:**  
You forgot to rebuild the image:
```bash
docker build -t my-image .
```
Then rerun the container using the updated image.

---

### 9. **What is the difference between `CMD` and `ENTRYPOINT` in Dockerfile?**

**Answer:**
- `CMD` provides **default args** that can be overridden at runtime
- `ENTRYPOINT` defines the **main command**, and is rarely overridden

---

### 10. **What happens when you delete a running container vs a stopped one?**

**Answer:**
- You can’t delete a running container. You must stop it first:
```bash
docker stop <id>
docker rm <id>
```
If you want to remove running containers:
```bash
docker rm -f <id>
```

---
