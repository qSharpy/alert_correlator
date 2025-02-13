#!/bin/bash

# Start the Flask backend in the background
echo "Starting Flask backend..."
python backend/alert_correlator.py &
FLASK_PID=$!

# Wait a moment to ensure Flask has started
sleep 2

# Check if Flask is running
if ! kill -0 $FLASK_PID 2>/dev/null; then
    echo "Flask backend failed to start"
    exit 1
fi

echo "Flask backend started successfully"

# Start the Express server
echo "Starting Express server..."
node server.js

# If Express exits, kill Flask and exit
kill $FLASK_PID
exit 0