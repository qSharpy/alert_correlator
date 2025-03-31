const express = require('express');
const path = require('path');
const app = express();
const port = 3005;

// Serve static files from the current directory
app.use(express.static(__dirname));

// Serve the index.html file for the root path
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'index.html'));
});

// Start the server
app.listen(port, () => {
  console.log(`Alert Correlator Demo running at http://localhost:${port}`);
  console.log('Press Ctrl+C to stop the server');
});