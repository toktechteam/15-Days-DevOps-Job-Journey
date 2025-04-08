const express = require('express');
const mysql = require('mysql2');
const app = express();
const port = 3000;

const db = mysql.createConnection({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASS || '',
  database: process.env.DB_NAME || 'test'
});

function connectWithRetry(retries = 10, delay = 3000) {
  const tryConnect = () => {
    db.connect(err => {
      if (err) {
        if (retries === 0) {
          console.error("❌ MySQL connection failed after retries. Exiting.");
          process.exit(1);
        }
        console.log(`⏳ Waiting for MySQL... Retries left: ${retries}`);
        retries--;
        setTimeout(tryConnect, delay);
      } else {
        console.log("✅ Connected to MySQL");
        setupApp();
      }
    });
  };

  tryConnect();
}

function setupApp() {
  app.get('/api', (_, res) => {
    res.status(200).send("✅ Backend is UP and connected to DB.");
  });

  // Optional: still allow original DB time test
  app.get('/db-time', (req, res) => {
    db.query('SELECT NOW() AS current_time', (err, results) => {
      if (err) {
        return res.status(500).send("❌ DB Error: " + err.message);
      }
      res.send("👋 DB time: " + results[0].current_time);
    });
  });

  app.listen(port, '0.0.0.0', () => {
    console.log(`✅ Backend listening at http://0.0.0.0:${port}`);
  });
}

connectWithRetry();

