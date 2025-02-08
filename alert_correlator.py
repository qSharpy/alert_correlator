import time
from datetime import datetime, timedelta
import threading
from flask import Flask, request, jsonify
import openai
import os
import logging

# Configure logging to output timestamp, level, and message.
logging.basicConfig(level=logging.INFO, format='%(asctime)s [%(levelname)s] %(message)s')

app = Flask(__name__)

# Configuration: adjust these for demo vs. production
# For demo, we use short intervals (in seconds). In production, these might be in minutes.
INACTIVITY_GAP = 60          # e.g., 60 seconds of inactivity closes the session
MAX_SESSION_DURATION = 1800  # e.g., 1800 seconds (30 minutes) maximum session window

# Set your OpenAI API key via environment variable
openai.api_key = os.getenv("OPENAI_API_KEY")
if not openai.api_key:
    raise Exception("Please set your OPENAI_API_KEY environment variable")

# Global session storage and a lock to avoid race conditions
current_session = None
session_lock = threading.Lock()

def create_new_session(alert):
    """Creates a new alert session starting with the given alert."""
    now = datetime.utcnow()
    session = {
        "start_time": now,
        "last_alert_time": now,
        "alerts": [alert]
    }
    logging.info(f"New session created at {now.isoformat()} with initial alert: {alert}")
    return session

@app.route('/alert', methods=['POST'])
def receive_alert():
    """
    Endpoint to receive an alert.
    Expected JSON format (simplified Prometheus alert):
    {
        "alert_name": "HighErrorRate",
        "severity": "critical",
        "description": "Error rate exceeded threshold on service XYZ"
    }
    """
    global current_session
    alert = request.get_json()
    now = datetime.utcnow()

    with session_lock:
        if current_session is None:
            current_session = create_new_session(alert)
        else:
            current_session["alerts"].append(alert)
            current_session["last_alert_time"] = now
            logging.info(f"Added alert at {now.isoformat()}: {alert}")

    return jsonify({"status": "alert received"}), 200

def generate_incident_report(alerts):
    """
    Uses the OpenAI API to generate an incident report based on the list of alerts.
    """
    # Construct a summary of the alerts
    alert_descriptions = "\n".join(
        [f"- {a.get('alert_name', 'Unknown')}: {a.get('description', 'No description')}" for a in alerts]
    )
    prompt = f"""
We received the following alerts:
{alert_descriptions}

Please provide an incident summary that correlates these alerts, identifies potential root causes, and suggests remediation steps.
    """
    try:
        response = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": "You are an incident response assistant."},
                {"role": "user", "content": prompt}
            ],
            max_tokens=150,
            temperature=0.7
        )
        incident_report = response.choices[0].message['content'].strip()
        logging.info("Incident report generated successfully.")
    except Exception as e:
        incident_report = f"Error generating incident report: {e}"
        logging.error(incident_report)
    return incident_report

def session_monitor():
    """
    Background thread that periodically checks the current alert session.
    If the inactivity gap has passed or the maximum session duration is reached,
    it processes the session by generating an incident report.
    """
    global current_session
    while True:
        time.sleep(10)  # Check every 10 seconds
        with session_lock:
            if current_session is not None:
                now = datetime.utcnow()
                session_age = (now - current_session["start_time"]).total_seconds()
                inactivity_duration = (now - current_session["last_alert_time"]).total_seconds()

                logging.info(f"Checking session: age={session_age:.1f}s, inactivity={inactivity_duration:.1f}s")

                # Close session if no new alerts within the inactivity gap
                # or if maximum session duration is reached.
                if inactivity_duration >= INACTIVITY_GAP or session_age >= MAX_SESSION_DURATION:
                    logging.info("Session window closed. Processing alerts...")
                    alerts = current_session["alerts"]
                    report = generate_incident_report(alerts)
                    logging.info("Generated Incident Report:")
                    logging.info("\n" + report)
                    # Reset the session
                    current_session = None

if __name__ == '__main__':
    # Start the background thread for monitoring the alert session
    monitor_thread = threading.Thread(target=session_monitor, daemon=True)
    monitor_thread.start()

    # Start the Flask app on port 5000
    logging.info("Starting Flask app on port 5000")
    app.run(host="0.0.0.0", port=5000)
