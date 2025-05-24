const mysql = require('mysql2/promise');

// Database connection configuration
const dbConfig = {
  host: process.env.DB_HOST || 'localhost', // Changed from 'mysql' to 'localhost'
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || 'root_password', // Updated to match MariaDB password
  database: process.env.DB_NAME || 'student_management',
  port: process.env.DB_PORT || 3306,
  // Additional connection options for better reliability
  acquireTimeout: 60000,
  timeout: 60000,
  reconnect: true
};

// Create and export the database connection pool
const pool = mysql.createPool(dbConfig);

// Test connection on startup
pool.getConnection()
  .then(connection => {
    console.log('✅ Database connected successfully');
    connection.release();
  })
  .catch(err => {
    console.error('❌ Database connection failed:', err.message);
  });

module.exports = pool;