# 🌟 Mini Interview Prep (Bonus)

### Q. What is the role of Prometheus in monitoring?
**Answer:**
- Prometheus is a time-series database that **collects and stores metrics** by scraping targets.

### Q. What is Grafana used for?
**Answer:**
- Grafana **visualizes metrics** stored in Prometheus (or other databases) via beautiful, customizable dashboards.

### Q. Why use Docker Compose for setting up monitoring tools?
**Answer:**
- Simplifies multi-container setup
- Easily replicable and portable
- Great for Dev, Testing, and Demo Environments

### Q. What is the default scrape interval in Prometheus and what does it mean?
**Answer:**
- The default scrape interval is **15 seconds**.
- It means Prometheus will collect (scrape) metrics from configured targets every 15 seconds.

### Q. What is a Prometheus "scrape config"?
**Answer:**
- A scrape config defines **what targets** Prometheus should scrape metrics from.
- Example: Setting Prometheus itself as a target at `localhost:9090`.

### Q. Why should you secure Grafana dashboards in production?
**Answer:**
- Default login (admin/admin) is insecure.
- Without securing dashboards, **unauthorized users can access sensitive system metrics**.
- Always change admin password and configure access policies.

### Q. Can Prometheus monitor itself?
**Answer:**
- **Yes**, Prometheus can scrape and monitor its own metrics.
- It's useful for understanding Prometheus server health and performance.

### Q. What is the advantage of using Grafana with Prometheus?
**Answer:**
- Prometheus stores raw metrics.
- Grafana makes it **human-friendly** by offering visualizations, graphs, alerts, and real-time dashboards.

---
