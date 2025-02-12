const express = require('express');
const path = require('path');
const app = express();
const port = 3000;

// Serve static files
app.use(express.static('.'));

// Serve runbooks directory
app.use('/runbooks', express.static('runbooks'));

// Handle all routes by serving index.html
app.get('*', (req, res) => {
    res.sendFile(path.join(__dirname, 'index.html'));
});

app.listen(port, () => {
    console.log(`Alert Runbooks server running at http://localhost:${port}`);
});