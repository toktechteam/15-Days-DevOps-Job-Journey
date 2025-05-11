
# 🐳 Docker Compose – Real DevOps Interview Questions
---

### 1. **Your app has 3 services: web, API, and DB. How will Docker Compose ensure they all talk to each other securely?**

**Answer:**  
Docker Compose creates a default network where all services can reach each other using their **service names** as hostnames.  
So the `web` service can reach `api` at `http://api:3000` and `db` at `mysql://db:3306` without exposing them to the outside.

---

### 2. **What happens when you run `docker-compose up` and one of the services has a build context?**

**Answer:**  
Compose checks if the image exists locally. If not, it builds the image using the specified `Dockerfile` and `context`.  
This is useful when developing locally and rebuilding frequently.

---

### 3. **How can you ensure the database is fully ready before starting your backend service?**

**Answer:**  
Use `depends_on` with `condition: service_healthy` (available in v3.4+ Compose).  
You must define a `healthcheck` in the DB service:
```yaml
healthcheck:
  test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
  interval: 10s
  retries: 5
```

---

### 4. **You updated some frontend code. What’s the most efficient way to rebuild only that service in Compose?**

**Answer:**
```bash
docker-compose up -d --build frontend
```
This rebuilds the `frontend` service without disturbing others.

---

### 5. **Explain what happens under the hood when you run `docker-compose down`.**

**Answer:**
- Stops and removes all containers defined in the file
- Removes the default network created by Compose
- **Does not remove volumes unless** you use `--volumes` flag
```bash
docker-compose down --volumes
```

---

### 6. **How do you persist data across container restarts using Compose?**

**Answer:**  
Mount named volumes:
```yaml
volumes:
  - db-data:/var/lib/mysql

volumes:
  db-data:
```
This ensures MySQL data isn’t lost even if the container is removed.

---

### 7. **You’re running a React frontend + Node.js backend + MySQL DB. How would you structure your docker-compose.yml?**

**Answer:**
- Define 3 services: `frontend`, `backend`, and `mysql`
- Add `depends_on` so frontend waits for backend
- Mount volumes for the DB
- Use ports 3000, 8080, and 3306 appropriately  
  Also inject environment variables into backend to connect to MySQL using service name `mysql`.

---

### 8. **You keep getting connection errors from backend to MySQL. What’s your Compose-level debugging approach?**

**Answer:**
- Check logs using `docker-compose logs backend`
- `docker-compose exec backend ping mysql` to test network
- Verify DB credentials via `docker-compose exec backend env`
- Confirm MySQL healthcheck is passing

---

### 9. **How do you override environment variables in Compose without hardcoding them?**

**Answer:**  
Use an `.env` file in the same directory:
```dotenv
MYSQL_ROOT_PASSWORD=secret
```

In `docker-compose.yml`:
```yaml
environment:
  - MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
```

---

### 10. **Can you run multiple Compose files together for staging and prod? How?**

**Answer:**  
Yes. Use multiple files like:
```bash
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```
This merges the configurations — helpful for overriding image names, ports, or envs for different environments.

---
