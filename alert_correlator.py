import time
from datetime import datetime
import threading
from flask import Flask, request, jsonify
import openai
import os
import logging
from prometheus_client import Counter, Gauge, Histogram, generate_latest, CONTENT_TYPE_LATEST

# Configure logging
log_format = '%(asctime)s [%(levelname)s] %(message)s'
logging.basicConfig(
    level=logging.INFO,
    format=log_format,
    handlers=[
        logging.FileHandler('/var/log/alert_correlator.log', mode='a'),
        logging.StreamHandler()
    ]
)

logger = logging.getLogger()

app = Flask(__name__)

# Configuration: using short intervals for demo purposes.
INACTIVITY_GAP = 60          # seconds of inactivity before closing session
MAX_SESSION_DURATION = 1800  # maximum session window in seconds (30 minutes)

# Set your OpenAI API key via an environment variable
openai.api_key = os.getenv("OPENAI_API_KEY")
if not openai.api_key:
    raise Exception("Please set your OPENAI_API_KEY environment variable")

# Prometheus metrics
alerts_total = Counter(
    'alerts_total', 'Total number of alerts received', ['alert_name', 'severity', 'service']
)
active_session_alerts = Gauge(
    'active_session_alerts', 'Number of alerts in the current active session'
)
sessions_processed_total = Counter(
    'sessions_processed_total', 'Total number of sessions processed'
)
session_duration_seconds = Histogram(
    'session_duration_seconds', 'Duration of alert sessions in seconds'
)
session_alerts_total = Counter(
    'session_alerts_total', 'Total number of alerts processed in sessions'
)
incident_reports_generated_total = Counter(
    'incident_reports_generated_total', 'Total number of incident reports generated'
)

# Global session storage and a lock for thread safety.
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
    active_session_alerts.set(len(session["alerts"]))
    return session

@app.route('/alert', methods=['POST'])
def receive_alert():
    """
    Endpoint to receive an alert.
    Expected JSON (Prometheus-style alert, with an additional "service" label):
    {
        "alert_name": "HighErrorRate",
        "severity": "critical",
        "service": "ServiceA",
        "description": "Error rate exceeded threshold on ServiceA"
    }
    """
    global current_session
    alert = request.get_json()
    now = datetime.utcnow()
    # Extract labels (using "unknown" if not provided)
    alert_name = alert.get("alert_name", "unknown")
    severity = alert.get("severity", "unknown")
    service = alert.get("service", "unknown")

    # Increment the alert counter with labels.
    alerts_total.labels(alert_name=alert_name, severity=severity, service=service).inc()

    with session_lock:
        if current_session is None:
            current_session = create_new_session(alert)
        else:
            current_session["alerts"].append(alert)
            current_session["last_alert_time"] = now
            active_session_alerts.set(len(current_session["alerts"]))
            logging.info(f"Added alert at {now.isoformat()}: {alert}")

    return jsonify({"status": "alert received"}), 200

@app.route('/metrics')
def metrics():
    """Expose Prometheus metrics."""
    return generate_latest(), 200, {"Content-Type": CONTENT_TYPE_LATEST}

def generate_incident_report(alerts):
    """
    Uses the OpenAI API to generate an incident report based on the list of alerts.
    """
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
        incident_reports_generated_total.inc()
        logging.info("Incident report generated successfully.")
    except Exception as e:
        incident_report = f"Error generating incident report: {e}"
        logging.error(incident_report)
    return incident_report

def session_monitor():
    """
    Background thread that periodically checks the current alert session.
    If the inactivity gap or maximum session duration is reached,
    processes the session by generating an incident report.
    """
    global current_session
    while True:
        time.sleep(10)  # check every 10 seconds
        with session_lock:
            if current_session is not None:
                now = datetime.utcnow()
                session_age = (now - current_session["start_time"]).total_seconds()
                inactivity_duration = (now - current_session["last_alert_time"]).total_seconds()
                logging.info(f"Checking session: age={session_age:.1f}s, inactivity={inactivity_duration:.1f}s")

                if inactivity_duration >= INACTIVITY_GAP or session_age >= MAX_SESSION_DURATION:
                    logging.info("Session window closed. Processing alerts...")
                    alerts = current_session["alerts"]
                    report = generate_incident_report(alerts)
                    # Log incident report in JSON format for table view
                    logging.info({
                        "timestamp": datetime.utcnow().isoformat(),
                        "alert_count": len(alerts),
                        "duration_seconds": session_age,
                        "services": list(set(a.get('service', 'unknown') for a in alerts)),
                        "report": report
                    })
                    # Update session metrics
                    sessions_processed_total.inc()
                    session_duration_seconds.observe(session_age)
                    session_alerts_total.inc(len(alerts))
                    # Reset active session gauge and the session itself
                    active_session_alerts.set(0)
                    current_session = None

if __name__ == '__main__':
    # Start the background session monitor thread.
    monitor_thread = threading.Thread(target=session_monitor, daemon=True)
    monitor_thread.start()

    app.run(host="0.0.0.0", port=5000)
