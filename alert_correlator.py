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
incident_number = Counter(
    'incident_number', 'Counter for generating sequential incident numbers'
)
alert_resolution_time_seconds = Histogram(
    'alert_resolution_time_seconds', 'Time taken to resolve alerts'
)
correlated_alerts_total = Counter(
    'correlated_alerts_total', 'Total number of alerts that were correlated with others'
)
alerts_total = Counter(
    'alerts_total', 'Total number of alerts received', ['alert_name', 'severity', 'service', 'status']
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

def merge_labels_annotations(common_labels, common_annotations, alert_labels, alert_annotations):
    """Merge common labels/annotations with alert-specific ones."""
    labels = common_labels.copy() if common_labels else {}
    labels.update(alert_labels or {})
    
    annotations = common_annotations.copy() if common_annotations else {}
    annotations.update(alert_annotations or {})
    
    return labels, annotations

@app.route('/alert', methods=['POST'])
def receive_alert():
    """
    Endpoint to receive alerts from AlertManager webhook.
    Expected format:
    {
        "version": "4",
        "groupKey": <string>,
        "truncatedAlerts": <int>,
        "status": "<resolved|firing>",
        "receiver": <string>,
        "groupLabels": <object>,
        "commonLabels": <object>,
        "commonAnnotations": <object>,
        "externalURL": <string>,
        "alerts": [
            {
                "status": "<resolved|firing>",
                "labels": <object>,
                "annotations": <object>,
                "startsAt": "<rfc3339>",
                "endsAt": "<rfc3339>",
                "generatorURL": <string>,
                "fingerprint": <string>
            },
            ...
        ]
    }
    """
    global current_session
    
    try:
        webhook_data = request.get_json()
        if not webhook_data:
            raise ValueError("No JSON data received")
            
        # Extract common fields
        common_labels = webhook_data.get('commonLabels', {})
        common_annotations = webhook_data.get('commonAnnotations', {})
        group_key = webhook_data.get('groupKey', '')
        external_url = webhook_data.get('externalURL', '')
        webhook_status = webhook_data.get('status', 'unknown')
        
        # Log webhook metadata
        logging.info(f"Received AlertManager webhook - Status: {webhook_status}, GroupKey: {group_key}")
        if webhook_data.get('truncatedAlerts', 0) > 0:
            logging.warning(f"Alert group truncated - {webhook_data['truncatedAlerts']} alerts omitted")
            
        alerts_data = webhook_data.get('alerts', [])
        if not alerts_data:
            logging.warning("No alerts found in webhook data")
            return jsonify({"status": "warning", "message": "No alerts found in webhook data"}), 200
            
        for alert_data in alerts_data:
            now = datetime.utcnow()
            
            # Merge common labels/annotations with alert-specific ones
            labels, annotations = merge_labels_annotations(
                common_labels,
                common_annotations,
                alert_data.get('labels', {}),
                alert_data.get('annotations', {})
            )
            
            # Create normalized alert format
            alert = {
                "alert_name": labels.get("alertname", "unknown"),
                "severity": labels.get("severity", "unknown"),
                "service": labels.get("job", "unknown"),
                "instance": labels.get("instance", "unknown"),
                "description": annotations.get("description", "No description provided"),
                "runbook_url": annotations.get("runbook_url") or labels.get("runbook", ""),
                "status": alert_data.get("status", "unknown"),
                "starts_at": alert_data.get("startsAt"),
                "ends_at": alert_data.get("endsAt"),
                "generator_url": alert_data.get("generatorURL"),
                "fingerprint": alert_data.get("fingerprint"),
                "group_key": group_key,
                "external_url": external_url,
                # Store all additional labels for reference
                "additional_labels": {k: v for k, v in labels.items() 
                                   if k not in ["alertname", "severity", "job", "instance", "runbook"]},
                # Store all additional annotations
                "additional_annotations": {k: v for k, v in annotations.items() 
                                        if k not in ["description", "runbook_url"]}
            }
            
            # Extract labels for metrics
            alert_name = alert["alert_name"]
            severity = alert["severity"]
            service = alert["service"]
            status = alert["status"]

            # Increment the alert counter with labels
            alerts_total.labels(
                alert_name=alert_name,
                severity=severity,
                service=service,
                status=status
            ).inc()

            with session_lock:
                if current_session is None:
                    current_session = create_new_session(alert)
                else:
                    current_session["alerts"].append(alert)
                    current_session["last_alert_time"] = now
                    active_session_alerts.set(len(current_session["alerts"]))
                    logging.info(f"Added alert at {now.isoformat()}: {alert}")

        return jsonify({
            "status": "success",
            "message": f"Processed {len(alerts_data)} alerts",
            "group_key": group_key
        }), 200
        
    except Exception as e:
        error_msg = f"Error processing webhook: {str(e)}"
        logging.error(error_msg)
        return jsonify({"status": "error", "message": error_msg}), 400

@app.route('/metrics')
def metrics():
    """Expose Prometheus metrics."""
    return generate_latest(), 200, {"Content-Type": CONTENT_TYPE_LATEST}

def generate_incident_report(alerts):
    """
    Uses the OpenAI API to generate an incident report based on the list of alerts.
    Returns a tuple of (incident_number, report).
    """
    # Get next incident number
    inc_num = int(incident_number._value.get()) + 1
    incident_number.inc()
    incident_id = f"INC{inc_num}"
    
    alert_descriptions = []
    for a in alerts:
        status_str = f"[{a['status'].upper()}]" if a['status'] != "unknown" else ""
        description = f"- {a['alert_name']} {status_str} ({a['severity']}) on {a['instance']}: {a['description']}"
        
        # Add any relevant metrics from additional labels
        metrics = [f"{k}={v}" for k, v in a.get('additional_labels', {}).items() 
                  if any(metric in k.lower() for metric in ['threshold', 'count', 'rate', 'latency', 'usage'])]
        if metrics:
            description += f" [Metrics: {', '.join(metrics)}]"
            
        # Add timing information if available
        if a.get('ends_at'):
            description += f" (Resolved at: {a['ends_at']})"
            
        alert_descriptions.append(description)
    
    alert_text = "\n".join(alert_descriptions)
    
    prompt = f"""
We received the following alerts:
{alert_text}

Please provide an incident analysis in the following format:
**Incident Summary:**
[A brief summary of the correlated alerts and their impact]

**Potential Root Causes:**
[List of potential root causes]

**Remediation Steps:**
[List of recommended steps to address the incident]
    """
    try:
        response = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": "You are an incident response assistant."},
                {"role": "user", "content": prompt}
            ],
            max_tokens=250,
            temperature=0.7
        )
        report = response.choices[0].message['content'].strip()
        
        # Append runbook URLs if available
        runbook_urls = [f"{a['alert_name']}: {a['runbook_url']}"
                       for a in alerts if a.get('runbook_url')]
        if runbook_urls:
            report += "\n\n**Runbook URLs:**\n" + "\n".join(runbook_urls)
        
        # Append external URLs if available
        external_urls = set(a['external_url'] for a in alerts if a.get('external_url'))
        if external_urls:
            report += "\n\n**AlertManager URLs:**\n" + "\n".join(external_urls)
        
        incident_reports_generated_total.inc()
        logging.info("Incident report generated successfully.")
    except Exception as e:
        report = f"Error generating incident report: {e}"
        logging.error(report)
    return incident_id, report

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
                    incident_id, report = generate_incident_report(alerts)
                    # Log incident report in table format
                    logging.info(f"Generated Incident Report:")
                    logging.info(f"{incident_id} | {report}")
                    # Update session metrics
                    sessions_processed_total.inc()
                    session_duration_seconds.observe(session_age)
                    session_alerts_total.inc(len(alerts))
                    
                    # Track resolution time and correlated alerts
                    resolution_time = (current_session["last_alert_time"] - current_session["start_time"]).total_seconds()
                    alert_resolution_time_seconds.observe(resolution_time)
                    
                    # If we have multiple alerts in the session, they were correlated
                    if len(alerts) > 1:
                        correlated_alerts_total.inc(len(alerts))
                    
                    # Reset active session gauge and the session itself
                    active_session_alerts.set(0)
                    current_session = None

if __name__ == '__main__':
    # Start the background session monitor thread.
    monitor_thread = threading.Thread(target=session_monitor, daemon=True)
    monitor_thread.start()

    app.run(host="0.0.0.0", port=5000)
