const express = require('express');
const cors = require('cors');
const pool = require('./db');
const { register, metricsMiddleware } = require('./metrics');

// Initialize express app
const app = express();
const PORT = process.env.BACKEND_PORT || 3000;

// Middleware - Enhanced CORS settings
app.use(cors({
  origin: '*',  // Allow all origins (be careful in production)
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));
app.use(express.json());

// Apply metrics middleware for all routes
app.use(metricsMiddleware);

// Metrics endpoint for Prometheus
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

// Test route for root path
app.get('/', (req, res) => {
  res.json({ message: 'Student Management System API is running' });
});

// Routes

// GET all students
app.get('/api/students', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM students');
    res.json(rows);
  } catch (error) {
    console.error('Error fetching students:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// GET student by ID
app.get('/api/students/:id', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM students WHERE id = ?', [req.params.id]);

    if (rows.length === 0) {
      return res.status(404).json({ message: 'Student not found' });
    }

    res.json(rows[0]);
  } catch (error) {
    console.error('Error fetching student:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// CREATE a new student
app.post('/api/students', async (req, res) => {
  const { name, email, course } = req.body;

  // Debug log
  console.log('Received POST request with data:', req.body);

  // Simple validation
  if (!name || !email || !course) {
    return res.status(400).json({
      message: 'Please provide name, email and course',
      received: { name, email, course }
    });
  }

  try {
    const [result] = await pool.query(
      'INSERT INTO students (name, email, course) VALUES (?, ?, ?)',
      [name, email, course]
    );

    console.log('Student created successfully:', { id: result.insertId, name, email, course });

    res.status(201).json({
      id: result.insertId,
      name,
      email,
      course
    });
  } catch (error) {
    console.error('Error creating student:', error);
    res.status(500).json({
      message: 'Server error',
      error: error.message,
      sqlState: error.sqlState  // Additional SQL error info
    });
  }
});

// UPDATE a student
app.put('/api/students/:id', async (req, res) => {
  const { name, email, course } = req.body;
  const id = req.params.id;

  // Simple validation
  if (!name || !email || !course) {
    return res.status(400).json({ message: 'Please provide name, email and course' });
  }

  try {
    const [result] = await pool.query(
      'UPDATE students SET name = ?, email = ?, course = ? WHERE id = ?',
      [name, email, course, id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'Student not found' });
    }

    res.json({ id, name, email, course });
  } catch (error) {
    console.error('Error updating student:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// DELETE a student
app.delete('/api/students/:id', async (req, res) => {
  try {
    const [result] = await pool.query('DELETE FROM students WHERE id = ?', [req.params.id]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'Student not found' });
    }

    res.json({ message: 'Student deleted successfully' });
  } catch (error) {
    console.error('Error deleting student:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Error handling for undefined routes
app.use((req, res) => {
  res.status(404).json({ message: 'Route not found' });
});

// Start the server
//app.listen(PORT, () => {
//  console.log(`Server running on http://localhost:${PORT}`);
//  console.log(`Test the API at http://localhost:${PORT}/api/students`);
//  console.log(`Metrics available at http://localhost:${PORT}/metrics`);
//});
//
// Start the server | Change the app.listen line to:
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on http://0.0.0.0:${PORT}`);
  console.log(`Test the API at http://0.0.0.0:${PORT}/api/students`);
  console.log(`Metrics available at http://0.0.0.0:${PORT}/metrics`);
});
