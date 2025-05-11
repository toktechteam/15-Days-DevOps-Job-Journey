const mysql = require('mysql2/promise');

// Database connection configuration
const dbConfig = {
  host: process.env.DB_HOST || 'mysql', // Use the service name from docker-compose
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || 'root_password', // Make sure this matches your docker-compose
  database: process.env.DB_NAME || 'student_management'
};

// Create and export the database connection pool
const pool = mysql.createPool(dbConfig);

module.exports = pool;
