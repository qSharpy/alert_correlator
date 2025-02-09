import requests
import json
import time

def send_alert(alert):
    """Send alert to Alertmanager with transformed format"""
    # Transform to our backend format
    transformed_alert = {
        "alert_name": alert["labels"]["alertname"],
        "severity": alert["labels"]["severity"],
        "service": alert["labels"]["job"],
        "description": alert["annotations"]["description"]
    }
    
    # Send to alert correlator directly (simulating Alertmanager webhook)
    response = requests.post(
        "http://localhost:5000/alert",
        json=transformed_alert,
        headers={"Content-Type": "application/json"}
    )
    return response.status_code

def main():
    # Test alerts from example_alerts.sh
    alerts = [
        {
            "labels": {
                "alertname": "AlertmanagerHighMemoryUsage",
                "severity": "warning",
                "instance": "alertmanager-main-0",
                "job": "alertmanager"
            },
            "annotations": {
                "summary": "Alertmanager high memory usage",
                "description": "Alertmanager instance alertmanager-main-0 is using more than 85% of its memory.",
                "runbook_url": "http://localhost:3000/#alertmanager/high_memory_usage"
            }
        },
        {
            "labels": {
                "alertname": "PrometheusHighQueryLoad",
                "severity": "warning",
                "instance": "prometheus-k8s-0",
                "job": "prometheus"
            },
            "annotations": {
                "summary": "Prometheus high query load",
                "description": "Prometheus instance prometheus-k8s-0 is experiencing high query load.",
                "runbook_url": "http://localhost:3000/#prometheus/high_query_load"
            }
        }
    ]

    print("Starting alert test flow...")
    for alert in alerts:
        print(f"\nSending alert: {alert['labels']['alertname']}")
        status = send_alert(alert)
        print(f"Response status: {status}")
        time.sleep(2)  # Wait between alerts

if __name__ == "__main__":
    main()