const mysql = require('mysql2/promise');

// Database connection configuration
const dbConfig = {
  host: 'localhost',
  user: 'root',     // Change to your MySQL username
  password: 'Tory1c0m$db',     // Change to your MySQL password
  database: 'student_management'
};

// Create and export the database connection pool
const pool = mysql.createPool(dbConfig);

module.exports = pool;