// metrics.js
const promClient = require('prom-client');

// Create a Registry to register the metrics
const register = new promClient.Registry();

// Enable the collection of default metrics
promClient.collectDefaultMetrics({ register });

// Create custom metrics
const httpRequestsTotal = new promClient.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status'],
  registers: [register]
});

const httpRequestDurationSeconds = new promClient.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status'],
  buckets: [0.01, 0.05, 0.1, 0.5, 1, 2.5, 5, 10],
  registers: [register]
});

// Middleware for Express.js to record metrics
const metricsMiddleware = (req, res, next) => {
  const start = Date.now();

  // Record the request method and path
  const route = req.route ? req.route.path : req.path;
  const method = req.method;

  // Add a listener for the response finish event
  res.on('finish', () => {
    // Record the status code
    const status = res.statusCode;

    // Increment the counter
    httpRequestsTotal.inc({ method, route, status });

    // Record the response time
    const duration = (Date.now() - start) / 1000;
    httpRequestDurationSeconds.observe({ method, route, status }, duration);
  });

  next();
};

// Export the metrics middleware and registry
module.exports = { register, metricsMiddleware };
